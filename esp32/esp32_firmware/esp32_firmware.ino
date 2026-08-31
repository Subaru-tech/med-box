/*
 * ================================================================
 * ElderLink Smart Medicine Box — ESP32 Firmware
 * ================================================================
 * Implements the local HTTP API the ElderLink Flutter app talks to
 * directly over LAN (see lib/services/network_service.dart):
 *
 *   GET  /ping             -> "pong"                  (online check)
 *   GET  /status           -> JSON device telemetry
 *   POST /send-message     -> {text, sender}
 *   POST /set-medication   -> {name, slot, hour, minute}
 *   POST /set-appointment  -> {title, year, month, day, hour, minute, notes}
 *
 * Hardware (no reed switch — dose confirmation is button-only):
 *   Push button    -> GPIO 26 (external 10k pull-down to GND)
 *                     short press = confirm/silence, long press (3s+) = SOS
 *   Active buzzer  -> GPIO 25 (via 220ohm resistor)
 *   Red LED        -> GPIO 33 (via 220ohm resistor, missed dose)
 *   Green LED      -> GPIO 32 (via 220ohm resistor, taken / confirmed)
 *   SSD1306 OLED   -> I2C, GPIO 21 (SDA) / GPIO 22 (SCL), address 0x3C
 *   DS3231 RTC     -> shares the same I2C bus (optional — falls back to NTP)
 *
 * Required Arduino libraries (install via Library Manager):
 *   - ArduinoJson (Benoit Blanchon) — version 7.x
 *   - Adafruit SSD1306
 *   - Adafruit GFX Library
 *   - RTClib (Adafruit) + Adafruit BusIO   [optional — see USE_RTC below]
 *
 * Board: any ESP32 dev board (e.g. "ESP32 Dev Module") via the
 * espressif/arduino-esp32 board package.
 *
 * SETUP:
 *   1. Fill in WIFI_PASSWORD below (open this file yourself and type it
 *      in directly — safer than pasting a real WiFi password into chat).
 *   2. Flash this sketch.
 *   3. Open Serial Monitor (115200 baud) to read the assigned IP address.
 *   4. In the app: Settings -> ElderLink Device -> Register Device,
 *      enter that IP address.
 *
 * NOTE: The push-button long-press (SOS) and short-press dose
 * confirmation are handled locally on the device (buzzer, LEDs, OLED)
 * only. Pushing those events up to Firestore as alerts/dose logs is
 * NOT wired in this build — the project's current Firestore security
 * rules require an authenticated user and don't cover the
 * medications/messages/appointments/alerts collections the app
 * actually uses, so writes from the device (or the app itself) would
 * be rejected today. That's a separate fix (auth + rules), not a
 * firmware problem.
 * ================================================================
 */

#include <WiFi.h>
#include <WebServer.h>
#include <ArduinoJson.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <time.h>

// Set to 0 if you don't have a DS3231 wired up yet — the device will
// keep time via NTP over WiFi instead so you can still test the app.
#define USE_RTC 1
#if USE_RTC
#include <RTClib.h>
RTC_DS3231 rtc;
bool rtcAvailable = false;
#endif

// =================== CONFIGURATION ===================
#define WIFI_SSID       "atharva"
#define WIFI_PASSWORD   "REPLACE_WITH_YOUR_WIFI_PASSWORD"
#define DEVICE_NAME     "ElderLink Medicine Box"

// PINS
#define BUTTON_PIN      26
#define BUZZER_PIN      25
#define RED_LED_PIN     33
#define GREEN_LED_PIN   32
#define SDA_PIN         21
#define SCL_PIN         22

// OLED
#define OLED_WIDTH      128
#define OLED_HEIGHT     64
#define OLED_I2C_ADDR   0x3C   // try 0x3D if the screen stays blank

// TIMING
#define GRACE_PERIOD_MS       (5UL * 60UL * 1000UL)   // 5 min missed-dose window
#define MESSAGE_DISPLAY_MS    15000UL
#define APPOINTMENT_DISPLAY_MS 10000UL
#define CONFIRM_DISPLAY_MS    3000UL
#define LONG_PRESS_MS         3000UL
#define DEBOUNCE_MS           50UL
#define MAX_MED_SLOTS         12
#define MAX_APPOINTMENTS      5
#define SOS_BEEP_MS           150UL

// Timezone (IST default — change GMT_OFFSET_SEC for yours)
const long GMT_OFFSET_SEC = 19800;   // +5:30
const int  DST_OFFSET_SEC = 0;
const char* NTP_SERVER = "pool.ntp.org";

// =================== GLOBAL OBJECTS ===================
Adafruit_SSD1306 display(OLED_WIDTH, OLED_HEIGHT, &Wire, -1);
bool oledAvailable = false;
WebServer server(80);

// =================== SCHEDULE STORAGE ===================
struct MedSlot {
  bool active;
  String name;
  String slot;       // "morning" | "afternoon" | "night"
  int hour, minute;
  bool firedToday;    // alarm has sounded for today's occurrence
  bool takenToday;    // confirmed via button during grace period
  int lastFiredDay;   // day-of-month this slot last fired, to reset daily
};

struct Appointment {
  bool active;
  String title;
  String notes;
  int year, month, day, hour, minute;
  bool notified;
};

MedSlot medSlots[MAX_MED_SLOTS];
Appointment appointments[MAX_APPOINTMENTS];

String lastMessageText = "";
String lastMessageSender = "";

// =================== DISPLAY STATE MACHINE ===================
enum DisplayMode {
  MODE_IDLE_CLOCK,
  MODE_MED_DUE,
  MODE_MED_MISSED,
  MODE_MED_CONFIRMED,
  MODE_MESSAGE,
  MODE_APPOINTMENT,
  MODE_SOS
};

DisplayMode displayMode = MODE_IDLE_CLOCK;
unsigned long displayModeUntil = 0;   // 0 = sticky until superseded
int activeMedSlotIndex = -1;

// =================== INPUT STATE ===================
bool buttonPressed = false;
unsigned long buttonDownAt = 0;
unsigned long lastButtonEdgeAt = 0;
bool longPressFired = false;

// =================== BUZZER ===================
bool buzzerOn = false;
int buzzerPattern = 0;   // 0 = continuous, >0 = number of SOS beeps remaining
unsigned long buzzerNextToggle = 0;

// =================== TIME HELPERS ===================
struct SimpleTime {
  int year, month, day, hour, minute, second;
};

bool getCurrentTime(SimpleTime &t) {
#if USE_RTC
  if (rtcAvailable) {
    DateTime now = rtc.now();
    t.year = now.year(); t.month = now.month(); t.day = now.day();
    t.hour = now.hour(); t.minute = now.minute(); t.second = now.second();
    return true;
  }
#endif
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo, 100)) return false;
  t.year = timeinfo.tm_year + 1900;
  t.month = timeinfo.tm_mon + 1;
  t.day = timeinfo.tm_mday;
  t.hour = timeinfo.tm_hour;
  t.minute = timeinfo.tm_min;
  t.second = timeinfo.tm_sec;
  return true;
}

// =================== SETUP ===================
void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println("\n[ElderLink] Booting...");

  pinMode(BUTTON_PIN, INPUT);   // external 10k pull-down already on the board
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);
  pinMode(GREEN_LED_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, LOW);

  for (int i = 0; i < MAX_MED_SLOTS; i++) medSlots[i].active = false;
  for (int i = 0; i < MAX_APPOINTMENTS; i++) appointments[i].active = false;

  Wire.begin(SDA_PIN, SCL_PIN);
  oledAvailable = display.begin(SSD1306_SWITCHCAPVCC, OLED_I2C_ADDR);
  if (oledAvailable) {
    display.setTextColor(SSD1306_WHITE);
    display.clearDisplay();
    display.setTextSize(1);
    display.setCursor(0, 0);
    display.println("ElderLink");
    display.setCursor(0, 12);
    display.println("Starting...");
    display.display();
  } else {
    Serial.println("[OLED] SSD1306 not found at 0x3C — check wiring/address.");
  }

#if USE_RTC
  rtcAvailable = rtc.begin();
  if (rtcAvailable && rtc.lostPower()) {
    Serial.println("[RTC] Lost power, time may be wrong until NTP syncs.");
  }
  Serial.println(rtcAvailable ? "[RTC] DS3231 found." : "[RTC] Not found, will rely on NTP.");
#endif

  connectWiFi();

  if (WiFi.status() == WL_CONNECTED) {
    configTime(GMT_OFFSET_SEC, DST_OFFSET_SEC, NTP_SERVER);
    struct tm timeinfo;
    if (getLocalTime(&timeinfo, 8000)) {
      Serial.println("[Time] NTP synced.");
#if USE_RTC
      if (rtcAvailable) {
        rtc.adjust(DateTime(timeinfo.tm_year + 1900, timeinfo.tm_mon + 1,
                             timeinfo.tm_mday, timeinfo.tm_hour,
                             timeinfo.tm_min, timeinfo.tm_sec));
      }
#endif
    } else {
      Serial.println("[Time] NTP sync failed.");
    }
  }

  server.on("/", HTTP_GET, handleRoot);
  server.on("/ping", HTTP_GET, handlePing);
  server.on("/status", HTTP_GET, handleStatus);
  server.on("/send-message", HTTP_POST, handleSendMessage);
  server.on("/set-medication", HTTP_POST, handleSetMedication);
  server.on("/set-appointment", HTTP_POST, handleSetAppointment);
  server.onNotFound([]() {
    server.sendHeader("Access-Control-Allow-Origin", "*");
    server.send(404, "application/json", "{\"error\":\"not found\"}");
  });
  server.begin();
  Serial.println("[Server] Listening on port 80.");

  showIdleClock(true);
}

void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.printf("[WiFi] Connecting to %s", WIFI_SSID);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("[WiFi] Connected. IP address: ");
    Serial.println(WiFi.localIP());
    if (oledAvailable) {
      display.clearDisplay();
      display.setTextSize(1);
      display.setCursor(0, 0);
      display.println("WiFi connected");
      display.setCursor(0, 16);
      display.println(WiFi.localIP().toString());
      display.display();
    }
    delay(3000);
  } else {
    Serial.println("[WiFi] Failed to connect. Check credentials.");
    if (oledAvailable) {
      display.clearDisplay();
      display.setTextSize(1);
      display.setCursor(0, 0);
      display.println("WiFi FAILED");
      display.setCursor(0, 16);
      display.println("Check password");
      display.display();
    }
  }
}

// =================== MAIN LOOP ===================
void loop() {
  server.handleClient();
  handleButton();
  handleBuzzer();
  checkMedicationSchedule();
  checkAppointmentSchedule();
  updateDisplay();
  delay(10);
}

void confirmDose(int idx) {
  stopBuzzer();
  digitalWrite(RED_LED_PIN, LOW);
  digitalWrite(GREEN_LED_PIN, HIGH);
  displayMode = MODE_MED_CONFIRMED;
  displayModeUntil = millis() + CONFIRM_DISPLAY_MS;
  Serial.printf("[Medicine] '%s' (%s) confirmed taken.\n",
                medSlots[idx].name.c_str(), medSlots[idx].slot.c_str());
}

// =================== BUTTON ===================
void handleButton() {
  bool reading = digitalRead(BUTTON_PIN) == HIGH;
  unsigned long now = millis();

  if (reading != buttonPressed && (now - lastButtonEdgeAt) > DEBOUNCE_MS) {
    lastButtonEdgeAt = now;
    buttonPressed = reading;

    if (buttonPressed) {
      buttonDownAt = now;
      longPressFired = false;
    } else {
      unsigned long heldFor = now - buttonDownAt;
      if (!longPressFired && heldFor < LONG_PRESS_MS) {
        onShortPress();
      }
    }
  }

  if (buttonPressed && !longPressFired && (now - buttonDownAt) >= LONG_PRESS_MS) {
    longPressFired = true;
    onLongPress();
  }
}

void onShortPress() {
  digitalWrite(GREEN_LED_PIN, LOW);
  digitalWrite(RED_LED_PIN, LOW);

  if (buzzerOn && activeMedSlotIndex >= 0) {
    medSlots[activeMedSlotIndex].takenToday = true;
    confirmDose(activeMedSlotIndex);
  } else {
    // No active alarm — dismiss whatever is showing back to the clock.
    displayMode = MODE_IDLE_CLOCK;
    displayModeUntil = 0;
  }
}

void onLongPress() {
  Serial.println("[SOS] Long press detected — emergency signal (local only).");
  stopBuzzer();
  buzzerPattern = 6;   // 6 short beeps
  buzzerOn = true;
  buzzerNextToggle = millis();
  digitalWrite(BUZZER_PIN, HIGH);
  digitalWrite(RED_LED_PIN, HIGH);
  displayMode = MODE_SOS;
  displayModeUntil = millis() + 8000;
}

// =================== BUZZER ===================
void stopBuzzer() {
  digitalWrite(BUZZER_PIN, LOW);
  buzzerOn = false;
  buzzerPattern = 0;
}

void handleBuzzer() {
  if (buzzerPattern <= 0) return;   // continuous alarm handled elsewhere, or idle
  unsigned long now = millis();
  if (now < buzzerNextToggle) return;

  bool currentlyHigh = digitalRead(BUZZER_PIN) == HIGH;
  digitalWrite(BUZZER_PIN, currentlyHigh ? LOW : HIGH);
  buzzerNextToggle = now + SOS_BEEP_MS;

  if (currentlyHigh) {
    buzzerPattern--;
    if (buzzerPattern <= 0) {
      digitalWrite(BUZZER_PIN, LOW);
      buzzerOn = false;
    }
  }
}

// =================== MEDICATION SCHEDULE ===================
void checkMedicationSchedule() {
  static unsigned long lastCheck = 0;
  if (millis() - lastCheck < 1000) return;
  lastCheck = millis();

  SimpleTime now;
  if (!getCurrentTime(now)) return;

  // Roll over "firedToday"/"takenToday" flags at day boundary.
  for (int i = 0; i < MAX_MED_SLOTS; i++) {
    if (!medSlots[i].active) continue;
    if (medSlots[i].lastFiredDay != now.day) {
      medSlots[i].firedToday = false;
      medSlots[i].takenToday = false;
    }
  }

  // Fire any due slot that hasn't fired yet today.
  for (int i = 0; i < MAX_MED_SLOTS; i++) {
    MedSlot &s = medSlots[i];
    if (!s.active || s.firedToday) continue;
    if (now.hour == s.hour && now.minute == s.minute) {
      s.firedToday = true;
      s.takenToday = false;
      s.lastFiredDay = now.day;
      activeMedSlotIndex = i;

      buzzerOn = true;
      buzzerPattern = 0;   // continuous until confirmed/missed
      digitalWrite(BUZZER_PIN, HIGH);
      displayMode = MODE_MED_DUE;
      displayModeUntil = millis() + GRACE_PERIOD_MS;

      Serial.printf("[Medicine] '%s' due now (%s %02d:%02d).\n",
                    s.name.c_str(), s.slot.c_str(), s.hour, s.minute);
    }
  }

  // Grace period expiry -> missed dose.
  if (displayMode == MODE_MED_DUE && activeMedSlotIndex >= 0 &&
      displayModeUntil != 0 && millis() >= displayModeUntil) {
    MedSlot &s = medSlots[activeMedSlotIndex];
    if (!s.takenToday) {
      digitalWrite(RED_LED_PIN, HIGH);
      displayMode = MODE_MED_MISSED;
      displayModeUntil = 0;   // sticky until button press
      Serial.printf("[Medicine] '%s' MISSED.\n", s.name.c_str());
    }
  }
}

// =================== APPOINTMENT SCHEDULE ===================
void checkAppointmentSchedule() {
  static unsigned long lastCheck = 0;
  if (millis() - lastCheck < 1000) return;
  lastCheck = millis();

  SimpleTime now;
  if (!getCurrentTime(now)) return;

  for (int i = 0; i < MAX_APPOINTMENTS; i++) {
    Appointment &a = appointments[i];
    if (!a.active || a.notified) continue;
    if (now.year == a.year && now.month == a.month && now.day == a.day &&
        now.hour == a.hour && now.minute == a.minute) {
      // A medicine alarm takes priority over the buzzer/OLED — don't mark
      // this notified yet so it retries once the alarm clears.
      if (displayMode == MODE_MED_DUE) continue;

      a.notified = true;
      buzzerPattern = 2;
      buzzerOn = true;
      buzzerNextToggle = millis();
      digitalWrite(BUZZER_PIN, HIGH);
      displayMode = MODE_APPOINTMENT;
      displayModeUntil = millis() + APPOINTMENT_DISPLAY_MS;
      Serial.printf("[Appointment] '%s' now.\n", a.title.c_str());
    }
  }
}

// =================== DISPLAY ===================
void updateDisplay() {
  static DisplayMode lastMode = MODE_IDLE_CLOCK;
  static int lastMedIdx = -1;
  static unsigned long lastClockRefresh = 0;

  if (!oledAvailable) return;

  if (displayModeUntil != 0 && millis() >= displayModeUntil &&
      displayMode != MODE_MED_DUE) {
    displayMode = MODE_IDLE_CLOCK;
    displayModeUntil = 0;
    digitalWrite(GREEN_LED_PIN, LOW);
  }

  bool changed = (displayMode != lastMode) ||
                 (displayMode == MODE_MED_DUE && activeMedSlotIndex != lastMedIdx);

  if (displayMode == MODE_IDLE_CLOCK) {
    if (millis() - lastClockRefresh < 1000 && !changed) return;
    lastClockRefresh = millis();
    showIdleClock(false);
  } else if (changed) {
    switch (displayMode) {
      case MODE_MED_DUE:
      case MODE_MED_MISSED:
        showMedicineAlert(displayMode == MODE_MED_MISSED);
        break;
      case MODE_MED_CONFIRMED:
        display.clearDisplay();
        display.setTextSize(1);
        display.setCursor(0, 0);
        display.println("MEDICINE TAKEN");
        printCentered("CONFIRMED", 30, 2);
        display.display();
        break;
      case MODE_MESSAGE:
        showMessage();
        break;
      case MODE_APPOINTMENT:
        showAppointment();
        break;
      case MODE_SOS:
        display.clearDisplay();
        printCentered("!! SOS !!", 16, 2);
        printCentered("Help is on the way", 44, 1);
        display.display();
        break;
      default:
        break;
    }
  }

  lastMode = displayMode;
  lastMedIdx = activeMedSlotIndex;
}

void printCentered(const String &text, int y, uint8_t size) {
  display.setTextSize(size);
  int16_t x1, y1;
  uint16_t w, h;
  display.getTextBounds(text, 0, y, &x1, &y1, &w, &h);
  int x = (OLED_WIDTH - (int)w) / 2;
  if (x < 0) x = 0;
  display.setCursor(x, y);
  display.println(text);
}

void showIdleClock(bool force) {
  if (!oledAvailable) return;
  SimpleTime t;
  static int lastMinute = -1;
  if (!getCurrentTime(t)) {
    if (force) {
      display.clearDisplay();
      display.setTextSize(1);
      display.setCursor(0, 0);
      display.println("ElderLink Ready");
      display.setCursor(0, 16);
      display.println(WiFi.status() == WL_CONNECTED ? WiFi.localIP().toString() : "No WiFi");
      display.display();
    }
    return;
  }
  if (!force && t.minute == lastMinute) return;
  lastMinute = t.minute;

  char timeStr[9];
  snprintf(timeStr, sizeof(timeStr), "%02d:%02d:%02d", t.hour, t.minute, t.second);

  display.clearDisplay();
  printCentered(timeStr, 16, 2);
  printCentered(WiFi.status() == WL_CONNECTED ? "ElderLink Ready" : "No WiFi", 48, 1);
  display.display();
}

void showMedicineAlert(bool missed) {
  MedSlot &s = medSlots[activeMedSlotIndex];
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println(missed ? "MEDICINE MISSED!" : "TIME FOR MEDICINE");
  display.drawFastHLine(0, 10, OLED_WIDTH, SSD1306_WHITE);
  printCentered(s.name.substring(0, 10), 24, 2);
  char timeStr[16];
  snprintf(timeStr, sizeof(timeStr), "%02d:%02d %s", s.hour, s.minute, s.slot.c_str());
  printCentered(timeStr, 52, 1);
  display.display();
}

void showMessage() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println(("From " + lastMessageSender).substring(0, 21));
  display.drawFastHLine(0, 10, OLED_WIDTH, SSD1306_WHITE);
  display.setCursor(0, 16);
  display.println(lastMessageText.substring(0, 21));
  if (lastMessageText.length() > 21) {
    display.setCursor(0, 26);
    display.println(lastMessageText.substring(21, 42));
  }
  display.display();
}

void showAppointment() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.println("Appointment now:");
  display.drawFastHLine(0, 10, OLED_WIDTH, SSD1306_WHITE);
  for (int i = 0; i < MAX_APPOINTMENTS; i++) {
    if (appointments[i].active && appointments[i].notified) {
      printCentered(appointments[i].title.substring(0, 16), 28, 1);
      break;
    }
  }
  display.display();
}

// =================== WEB HANDLERS ===================
void handleRoot() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String html = "<h1>" DEVICE_NAME "</h1>";
  html += "<p>Status: online</p>";
  html += "<p>Endpoints: /ping /status /send-message /set-medication /set-appointment</p>";
  server.send(200, "text/html", html);
}

void handlePing() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "text/plain", "pong");
}

void handleStatus() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  JsonDocument doc;
  doc["device"] = DEVICE_NAME;
  doc["online"] = true;
  doc["uptimeMs"] = millis();
  doc["freeHeap"] = ESP.getFreeHeap();
  doc["wifiRSSI"] = WiFi.RSSI();
  doc["oledAvailable"] = oledAvailable;
#if USE_RTC
  doc["rtcAvailable"] = rtcAvailable;
#else
  doc["rtcAvailable"] = false;
#endif
  String out;
  serializeJson(doc, out);
  server.send(200, "application/json", out);
}

bool parseJsonBody(JsonDocument &doc) {
  String body = server.arg("plain");
  DeserializationError err = deserializeJson(doc, body);
  return !err;
}

void handleSendMessage() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  JsonDocument doc;
  if (!parseJsonBody(doc)) {
    server.send(400, "application/json", "{\"error\":\"invalid json\"}");
    return;
  }

  lastMessageText = String((const char*)(doc["text"] | ""));
  lastMessageSender = String((const char*)(doc["sender"] | "Caregiver"));

  // A medicine alarm takes priority over the buzzer/OLED — the message is
  // still stored and acknowledged to the app, just not displayed until
  // the alarm clears.
  if (displayMode != MODE_MED_DUE) {
    buzzerPattern = 1;
    buzzerOn = true;
    buzzerNextToggle = millis();
    digitalWrite(BUZZER_PIN, HIGH);
    displayMode = MODE_MESSAGE;
    displayModeUntil = millis() + MESSAGE_DISPLAY_MS;
  }

  Serial.printf("[Message] From %s: %s\n", lastMessageSender.c_str(), lastMessageText.c_str());
  server.send(200, "application/json", "{\"status\":\"received\"}");
}

void handleSetMedication() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  JsonDocument doc;
  if (!parseJsonBody(doc)) {
    server.send(400, "application/json", "{\"error\":\"invalid json\"}");
    return;
  }

  String name = String((const char*)(doc["name"] | ""));
  String slot = String((const char*)(doc["slot"] | ""));
  int hour = doc["hour"] | -1;
  int minute = doc["minute"] | -1;

  if (name.isEmpty() || hour < 0 || minute < 0) {
    server.send(400, "application/json", "{\"error\":\"missing fields\"}");
    return;
  }

  // Reuse an existing slot with the same name+slot label, else find a free one.
  int target = -1;
  for (int i = 0; i < MAX_MED_SLOTS; i++) {
    if (medSlots[i].active && medSlots[i].name == name && medSlots[i].slot == slot) {
      target = i;
      break;
    }
  }
  if (target == -1) {
    for (int i = 0; i < MAX_MED_SLOTS; i++) {
      if (!medSlots[i].active) { target = i; break; }
    }
  }

  if (target == -1) {
    server.send(507, "application/json", "{\"error\":\"schedule full\"}");
    return;
  }

  medSlots[target].active = true;
  medSlots[target].name = name;
  medSlots[target].slot = slot;
  medSlots[target].hour = hour;
  medSlots[target].minute = minute;
  medSlots[target].firedToday = false;
  medSlots[target].takenToday = false;
  medSlots[target].lastFiredDay = -1;

  Serial.printf("[Schedule] '%s' (%s) set for %02d:%02d\n", name.c_str(), slot.c_str(), hour, minute);
  server.send(200, "application/json", "{\"status\":\"scheduled\"}");
}

void handleSetAppointment() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  JsonDocument doc;
  if (!parseJsonBody(doc)) {
    server.send(400, "application/json", "{\"error\":\"invalid json\"}");
    return;
  }

  int target = -1;
  for (int i = 0; i < MAX_APPOINTMENTS; i++) {
    if (!appointments[i].active) { target = i; break; }
  }
  if (target == -1) {
    // Overwrite the oldest (index 0) rather than reject, since this is a
    // small on-device buffer, not the source of truth (Firestore is).
    target = 0;
  }

  appointments[target].active = true;
  appointments[target].title = String((const char*)(doc["title"] | "Appointment"));
  appointments[target].notes = String((const char*)(doc["notes"] | ""));
  appointments[target].year = doc["year"] | 0;
  appointments[target].month = doc["month"] | 0;
  appointments[target].day = doc["day"] | 0;
  appointments[target].hour = doc["hour"] | 0;
  appointments[target].minute = doc["minute"] | 0;
  appointments[target].notified = false;

  Serial.printf("[Appointment] '%s' set for %04d-%02d-%02d %02d:%02d\n",
                appointments[target].title.c_str(), appointments[target].year,
                appointments[target].month, appointments[target].day,
                appointments[target].hour, appointments[target].minute);
  server.send(200, "application/json", "{\"status\":\"scheduled\"}");
}

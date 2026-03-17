/*
 * ================================================================
 * Smart Digital Notice Board - ESP32 Firmware (COMPLETE)
 * ================================================================
 * Version: 3.5 (SH1106 + U8G2 + Button + Screensaver + Scheduler 
 *               + Timezone + Buzzer + Animations)
 * Hardware: ESP32 DevKit V1 + SH1106 OLED + Push Button + Buzzer
 * 
 * FEATURES:
 * - WiFi Web Server with JSON API
 * - Button: Short=Next, Long=Clear
 * - Screensaver: Bouncing emojis + clock after 5 sec idle
 * - Scheduler: Optional date/time for notices
 * - Timezone: Configurable GMT offset with DST support
 * - Buzzer: 1-second beep when notice appears
 * - Animations: Slide, fade, typewriter effects for notices
 * ================================================================
 */

#include <WiFi.h>
#include <WebServer.h>
#include <Wire.h>
#include <U8g2lib.h>
#include <ArduinoJson.h>
#include <time.h>
#include <ESP32Time.h>

// =================== CONFIGURATION ===================
#define WIFI_SSID       "Airtel__Shadow_Ghost"
#define WIFI_PASSWORD   "**********"
#define DEVICE_NAME     "Notice Board"

// PINS
#define SDA_PIN         21
#define SCL_PIN         22
#define BUTTON_PIN      4
#define BUZZER_PIN      18          // GPIO 18 for buzzer

// TIMING
#define DEBOUNCE_MS     200
#define LONG_PRESS_MS   1000
#define MAX_NOTICES     10
#define IDLE_TIMEOUT_MS 30000
#define SCREENSAVER_SPEED 50
#define BUZZER_DURATION 1000        // 1 second beep

// =================== TIMEZONE CONFIG ===================
// Format: {GMT_OFFSET_SEC, DST_OFFSET_SEC, "Timezone Name"}
// Common timezones:
struct TimezoneConfig {
  long gmtOffsetSec;
  int daylightOffsetSec;
  const char* name;
  bool dstEnabled;
};

// Predefined timezones (select one or set custom)
TimezoneConfig TZ_IST = {19800, 0, "IST", false};           // India GMT+5:30
TimezoneConfig TZ_GMT = {0, 0, "GMT", false};               // GMT+0
TimezoneConfig TZ_EST = {-18000, 3600, "EST", true};        // GMT-5, DST +1
TimezoneConfig TZ_CET = {3600, 3600, "CET", true};          // GMT+1, DST +1
TimezoneConfig TZ_JST = {32400, 0, "JST", false};           // Japan GMT+9
TimezoneConfig TZ_AEST = {36000, 3600, "AEST", true};       // Australia GMT+10

// SELECT YOUR TIMEZONE HERE:
TimezoneConfig currentTZ = TZ_IST;  // Change to your timezone

// NTP Servers (regional for better sync)
const char* NTP_SERVERS[] = {
  "pool.ntp.org",
  "time.google.com",
  "time.windows.com"
};

// =================== GLOBAL OBJECTS ===================
U8G2_SH1106_128X64_NONAME_F_HW_I2C display(U8G2_R0, U8X8_PIN_NONE);
WebServer server(80);
ESP32Time rtc;

// =================== NOTICE STORAGE ===================
struct Notice {
  String title;
  String message;
  bool active;
  int year, month, day, hour, minute;
  bool displayed;
};

Notice notices[MAX_NOTICES];
int noticeCount = 0;
int currentNoticeIndex = 0;

// =================== INPUT/OUTPUT ===================
bool lastButtonState = HIGH;
unsigned long buttonPressTime = 0;
unsigned long lastDebounceTime = 0;
bool buttonHandled = false;
bool buzzerActive = false;
unsigned long buzzerStartTime = 0;

// =================== SCREENSAVER ===================
bool screensaverActive = false;
unsigned long lastActivityTime = 0;
int emojiX = 64, emojiY = 32;
int emojiDX = 2, emojiDY = 2;
int currentEmoji = 0;
int frame = 0;
int starX[10], starY[10];

// =================== TIME ===================
bool timeSynced = false;
struct tm timeinfo;

// =================== ANIMATION ===================
// (Animations removed per request)

// =================== EMOJIS ===================
const uint8_t emoji_smile[] = {0b00111100,0b01000010,0b10100101,0b10000001,0b10100101,0b10011001,0b01000010,0b00111100};
const uint8_t emoji_heart[] = {0b00000000,0b01100110,0b11111111,0b11111111,0b01111110,0b00111100,0b00011000,0b00000000};
const uint8_t emoji_star[] = {0b00010000,0b00111000,0b01111100,0b11111110,0b01111100,0b00111000,0b00010000,0b00000000};
const uint8_t emoji_note[] = {0b00001100,0b00001110,0b00001010,0b00001000,0b00001000,0b01111000,0b01111000,0b00000000};
const uint8_t emoji_bell[] = {0b00010000,0b00111000,0b00111000,0b00111000,0b01111100,0b00000000,0b00010000,0b00000000};
const uint8_t emoji_clock[] = {0b00111100,0b01000010,0b10000101,0b10001101,0b10010001,0b10100001,0b01000010,0b00111100};

const uint8_t* emojis[] = {emoji_smile, emoji_heart, emoji_star, emoji_note, emoji_bell, emoji_clock};

// Animation icons
const uint8_t icon_new[] = {0b00000000,0b00000100,0b00001110,0b00011111,0b00001110,0b00000100,0b00000000,0b00000000};
const uint8_t icon_alert[] = {0b00001000,0b00011100,0b00111110,0b01111111,0b00111110,0b00011100,0b00001000,0b00000000};

// =================== SETUP ===================
void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  
  // Random stars
  for(int i=0; i<10; i++) {
    starX[i] = random(0, 128);
    starY[i] = random(0, 64);
  }
  
  // Init display
  Wire.begin(SDA_PIN, SCL_PIN);
  if(!display.begin()) {
    Serial.println(F("[OLED] ERROR!"));
  }
  
  // Clear notices
  for(int i=0; i<MAX_NOTICES; i++) {
    notices[i].active = false;
    notices[i].displayed = false;
    notices[i].year = 0;
  }
  
  showBootScreen();
  
  // Connect WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 40) {
    delay(500);
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    // Show IP on screen
    display.clearBuffer();
    display.setFont(u8g2_font_ncenB14_tr);
    display.drawStr(5, 20, "WIFI CONNECTED");
    display.setFont(u8g2_font_ncenB08_tr);
    display.drawStr(10, 40, "IP Address:");
    display.setCursor(10, 55);
    display.print(WiFi.localIP().toString());
    display.sendBuffer();
    delay(3000);
    
    syncTime();
  }
  
  // Setup server
  server.on("/", handleRoot);
  server.on("/ping", handlePing);
  server.on("/get-time", handleGetTime);
  server.on("/set-timezone", handleSetTimezone);
  server.on("/list-notices", handleListNotices);
  server.on("/update-notice", handleUpdateNotice);
  server.begin();
  
  resetActivityTimer();
  showCurrentNotice();
  
  Serial.printf("[System] Ready! Timezone: %s (GMT%+ld)\n", 
    currentTZ.name, currentTZ.gmtOffsetSec/3600);
}

// =================== TIME SYNC ===================
void syncTime() {
  Serial.print("[Time] Syncing NTP...");
  
  configTime(currentTZ.gmtOffsetSec, 
             currentTZ.dstEnabled ? currentTZ.daylightOffsetSec : 0, 
             NTP_SERVERS[0], NTP_SERVERS[1], NTP_SERVERS[2]);
  
  int retries = 0;
  while (!timeSynced && retries < 15) {
    if (getLocalTime(&timeinfo)) {
      timeSynced = true;
      rtc.setTimeStruct(timeinfo);
      Serial.println(" OK!");
      Serial.printf("[Time] %02d/%02d/%04d %02d:%02d:%02d %s\n",
        timeinfo.tm_mday, timeinfo.tm_mon+1, timeinfo.tm_year+1900,
        timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec,
        currentTZ.name);
    } else {
      delay(800);
      retries++;
      Serial.print(".");
    }
  }
  
  if (!timeSynced) Serial.println(" FAILED!");
}

void updateTime() {
  static unsigned long lastUpdate = 0;
  if (millis() - lastUpdate > 1000) {
    timeinfo = rtc.getTimeStruct();
    lastUpdate = millis();
    
    // Auto DST adjustment (simplified - real DST needs date rules)
    if (currentTZ.dstEnabled && isDST()) {
      // Apply DST offset if not already applied
    }
  }
}

// Simple DST check (Northern Hemisphere approximation)
bool isDST() {
  if (!currentTZ.dstEnabled) return false;
  int month = timeinfo.tm_mon + 1; // 1-12
  int day = timeinfo.tm_mday;
  // DST: Last Sunday March to Last Sunday October
  if (month < 3 || month > 10) return false;
  if (month > 3 && month < 10) return true;
  // March/October boundary check (simplified)
  return (month == 3 && day > 25) || (month == 10 && day < 25);
}

bool isTimeDue(Notice* n) {
  if (n->year == 0) return true;
  
  if (timeinfo.tm_year + 1900 < n->year) return false;
  if (timeinfo.tm_year + 1900 > n->year) return true;
  
  if (timeinfo.tm_mon + 1 < n->month) return false;
  if (timeinfo.tm_mon + 1 > n->month) return true;
  
  if (timeinfo.tm_mday < n->day) return false;
  if (timeinfo.tm_mday > n->day) return true;
  
  if (timeinfo.tm_hour < n->hour) return false;
  if (timeinfo.tm_hour > n->hour) return true;
  
  return timeinfo.tm_min >= n->minute;
}

// =================== MAIN LOOP ===================
void loop() {
  server.handleClient();
  handleButton();
  updateTime();
  checkScheduledNotices();
  handleBuzzer();
  handleScreensaver();
  delay(10);
}

// =================== BUZZER ===================
void triggerBuzzer() {
  buzzerActive = true;
  buzzerStartTime = millis();
  digitalWrite(BUZZER_PIN, HIGH);
  Serial.println("[Buzzer] ON - New notice!");
}

void handleBuzzer() {
  if (buzzerActive && (millis() - buzzerStartTime >= BUZZER_DURATION)) {
    digitalWrite(BUZZER_PIN, LOW);
    buzzerActive = false;
    Serial.println("[Buzzer] OFF");
  }
}

// =================== NOTICE RENDERING ===================
// Original animated drawing functions removed. Note: showCurrentNotice() handles display.

// =================== SCHEDULER ===================
void checkScheduledNotices() {
  static unsigned long lastCheck = 0;
  if (millis() - lastCheck < 5000) return;
  lastCheck = millis();
  
  for (int i = 0; i < MAX_NOTICES; i++) {
    if (notices[i].active && !notices[i].displayed && notices[i].year > 0) {
      if (isTimeDue(&notices[i])) {
        Serial.printf("[Scheduler] Notice '%s' is DUE!\n", notices[i].title.c_str());
        notices[i].displayed = true;
        currentNoticeIndex = i;
        noticeCount++;
        
        // TRIGGER BUZZER AND SHOW NOTICE!
        triggerBuzzer();
        showCurrentNotice();
        
        resetActivityTimer();
      }
    }
  }
}

// =================== SCREENSAVER ===================
void resetActivityTimer() {
  lastActivityTime = millis();
  if (screensaverActive) {
    screensaverActive = false;
    showCurrentNotice();
  }
}

bool isIdle() {
  return (millis() - lastActivityTime) > IDLE_TIMEOUT_MS;
}

void handleScreensaver() {
  if (isIdle() && !screensaverActive) {
    screensaverActive = true;
    Serial.println("[Screensaver] ON");
  }
  
  if (screensaverActive) {
    drawScreensaver();
    delay(SCREENSAVER_SPEED);
  }
}

void drawScreensaver() {
  display.clearBuffer();
  drawTwinklingStars();
  
  // Bouncing emoji
  emojiX += emojiDX;
  emojiY += emojiDY;
  if (emojiX <= 0 || emojiX >= 120) {
    emojiDX = -emojiDX;
    currentEmoji = random(0, 6);
  }
  if (emojiY <= 0 || emojiY >= 56) {
    emojiDY = -emojiDY;
    currentEmoji = random(0, 6);
  }
  
  drawEmoji(currentEmoji, emojiX, emojiY, 2);
  
  // Show current time
  if (timeSynced) {
    display.setFont(u8g2_font_ncenB14_tr);
    display.setCursor(25, 15);
    char timeStr[20];
    sprintf(timeStr, "%02d:%02d", timeinfo.tm_hour, timeinfo.tm_min);
    display.print(timeStr);
    
    // Date
    display.setFont(u8g2_font_ncenB08_tr);
    display.setCursor(20, 55);
    char dateStr[30];
    sprintf(dateStr, "%02d/%02d/%04d %s", 
      timeinfo.tm_mday, timeinfo.tm_mon+1, timeinfo.tm_year+1900,
      currentTZ.name);
    display.print(dateStr);
  }
  
  // Scrolling status
  display.setFont(u8g2_font_5x7_tr);
  String status = String(noticeCount) + " notices | " + 
                  (currentTZ.dstEnabled && isDST() ? "DST ON" : currentTZ.name);
  int width = display.getStrWidth(status.c_str());
  int x = 128 - ((frame * 2) % (width + 150));
  display.setCursor(x, 62);
  display.print(status);
  
  display.sendBuffer();
  frame++;
}

void drawTwinklingStars() {
  for(int i=0; i<10; i++) {
    if (random(0, 10) > 7) display.drawPixel(starX[i], starY[i]);
    if (random(0, 50) == 0) {
      starX[i] = random(0, 128);
      starY[i] = random(0, 64);
    }
  }
}

void drawEmoji(int index, int x, int y, int scale) {
  const uint8_t* bitmap = emojis[index];
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      if (bitmap[row] & (1 << (7 - col))) {
        display.drawBox(x + (col * scale), y + (row * scale), scale, scale);
      }
    }
  }
}

void drawBitmap(const uint8_t* bitmap, int x, int y, int scale) {
  for (int row = 0; row < 8; row++) {
    for (int col = 0; col < 8; col++) {
      if (bitmap[row] & (1 << (7 - col))) {
        display.drawBox(x + (col * scale), y + (row * scale), scale, scale);
      }
    }
  }
}

// =================== BUTTON ===================
void handleButton() {
  bool reading = digitalRead(BUTTON_PIN);
  
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }
  
  if ((millis() - lastDebounceTime) > DEBOUNCE_MS) {
    if (reading == LOW && !buttonHandled) {
      if (buttonPressTime == 0) buttonPressTime = millis();
      
      if ((millis() - buttonPressTime) > LONG_PRESS_MS) {
        clearCurrentNotice();
        resetActivityTimer();
        buttonHandled = true;
        buttonPressTime = 0;
      }
    }
    else if (reading == HIGH && buttonPressTime > 0 && !buttonHandled) {
      nextNotice();
      resetActivityTimer();
      buttonPressTime = 0;
    }
    else if (reading == HIGH) {
      buttonHandled = false;
      buttonPressTime = 0;
    }
  }
  lastButtonState = reading;
}

void nextNotice() {
  if (noticeCount <= 1) return;
  
  int attempts = 0;
  do {
    currentNoticeIndex = (currentNoticeIndex + 1) % MAX_NOTICES;
    attempts++;
  } while ((!notices[currentNoticeIndex].active || 
           (notices[currentNoticeIndex].year > 0 && !notices[currentNoticeIndex].displayed)) 
           && attempts < MAX_NOTICES);
  
  if (attempts < MAX_NOTICES) {
    // Show instantly when manually switching
    showCurrentNotice();
    // No buzzer for manual next (only for new notices)
  }
}

void clearCurrentNotice() {
  if (noticeCount > 1) {
    notices[currentNoticeIndex].active = false;
    noticeCount--;
    
    for(int i=0; i<MAX_NOTICES; i++) {
      if (notices[i].active && (notices[i].year == 0 || notices[i].displayed)) {
        currentNoticeIndex = i;
        break;
      }
    }
  } else {
    notices[currentNoticeIndex].title = "Cleared";
    notices[currentNoticeIndex].message = "Waiting...";
    notices[currentNoticeIndex].year = 0;
  }
  
  showCurrentNotice();
}

void flashScreen() {
  display.setDrawColor(0);
  display.drawBox(0, 0, 128, 64);
  display.sendBuffer();
  delay(50);
  showCurrentNotice();
}

// =================== DISPLAY ===================
void showBootScreen() {
  display.clearBuffer();
  display.setFont(u8g2_font_ncenB14_tr);
  display.drawStr(10, 20, "BOOT OK!");
  display.setFont(u8g2_font_ncenB08_tr);
  display.drawStr(0, 40, "Notice Board v3.5");
  display.setFont(u8g2_font_5x7_tr);
  display.drawStr(0, 55, "Timezone + Buzzer + Anim");
  display.sendBuffer();
  delay(1500);
}

void showCurrentNotice() {
  if (!notices[currentNoticeIndex].active) return;
  displayNotice(&notices[currentNoticeIndex]);
}

void displayNotice(Notice* n) {
  display.clearBuffer();
  
  // Title bar
  display.setDrawColor(1);
  display.drawBox(0, 0, 128, 14);
  display.setDrawColor(0);
  display.setFont(u8g2_font_ncenB08_tr);
  display.setCursor(2, 10);
  
  String title = n->title.substring(0, 15);
  if (n->year > 0 && !n->displayed) {
    title = "⏰ " + title;
  }
  display.print(title);
  
  // Counter
  String counter = String(currentNoticeIndex + 1) + "/" + String(noticeCount);
  display.setCursor(105, 10);
  display.print(counter);
  
  // Message
  display.setDrawColor(1);
  display.setFont(u8g2_font_ncenB08_tr);
  display.setCursor(0, 28);
  printWrappedText(n->message, 0, 28, 128, 14);
  
  // Footer info
  display.setFont(u8g2_font_5x7_tr);
  display.setCursor(0, 55);
  if (n->year > 0) {
    char timeStr[30];
    sprintf(timeStr, "%02d/%02d %02d:%02d %s", 
      n->day, n->month, n->hour, n->minute,
      n->displayed ? "SHOWN" : "PENDING");
    display.print(timeStr);
  }
  
  // Timezone indicator
  display.setCursor(90, 55);
  display.print(currentTZ.name);
  
  display.sendBuffer();
}

void printWrappedText(String text, int x, int y, int maxWidth, int lineHeight) {
  int len = text.length();
  int line = 0;
  String currentLine = "";
  
  for (int i = 0; i < len && line < 3; i++) {
    currentLine += text[i];
    int width = display.getStrWidth(currentLine.c_str());
    
    if (width >= maxWidth - 5 || text[i] == '\n') {
      display.setCursor(x, y + (line * lineHeight));
      display.print(currentLine);
      currentLine = "";
      line++;
    }
  }
  
  if (currentLine.length() > 0 && line < 3) {
    display.setCursor(x, y + (line * lineHeight));
    display.print(currentLine);
  }
}

// =================== WEB HANDLERS ===================
void handleRoot() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String html = "<h1>Smart Notice Board v3.5</h1>";
  html += "<p>Time: " + rtc.getTime("%A, %B %d %Y %H:%M:%S ") + currentTZ.name + "</p>";
  html += "<p>Timezone: GMT" + String(currentTZ.gmtOffsetSec/3600) + 
          (currentTZ.dstEnabled ? " (DST supported)" : "") + "</p>";
  html += "<p>Notices: " + String(noticeCount) + "</p>";
  html += "<p>Endpoints: /update-notice, /list-notices, /get-time, /set-timezone</p>";
  server.send(200, "text/html", html);
}

void handlePing() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "text/plain", "pong");
}

void handleGetTime() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  String json = "{\"time\":\"" + rtc.getTime("%Y-%m-%d %H:%M:%S") + "\",";
  json += "\"timezone\":\"" + String(currentTZ.name) + "\",";
  json += "\"gmt_offset\":" + String(currentTZ.gmtOffsetSec) + ",";
  json += "\"dst\":" + String(isDST() ? "true" : "false") + ",";
  json += "\"synced\":" + String(timeSynced ? "true" : "false") + "}";
  server.send(200, "application/json", json);
}

void handleSetTimezone() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
  if (server.method() != HTTP_POST) {
    server.send(405, "text/plain", "Method Not Allowed");
    return;
  }
  
  String body = server.arg("plain");
#if ARDUINOJSON_VERSION_MAJOR >= 7
  JsonDocument doc;
#else
  DynamicJsonDocument doc(256);
#endif
  
  if (deserializeJson(doc, body)) {
    server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
    return;
  }
  
  // Update timezone
  currentTZ.gmtOffsetSec = doc["gmt_offset"] | currentTZ.gmtOffsetSec;
  currentTZ.daylightOffsetSec = doc["dst_offset"] | currentTZ.daylightOffsetSec;
  currentTZ.dstEnabled = doc["dst_enabled"] | currentTZ.dstEnabled;
  const char* name = doc["name"];
  if (name) currentTZ.name = name;
  
  // Resync with new timezone
  syncTime();
  
  server.send(200, "application/json", "{\"status\":\"timezone_updated\"}");
  Serial.printf("[Timezone] Updated to %s (GMT%+ld)\n", 
    currentTZ.name, currentTZ.gmtOffsetSec/3600);
}

void handleListNotices() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  
#if ARDUINOJSON_VERSION_MAJOR >= 7
  JsonDocument doc;
#else
  DynamicJsonDocument doc(2048);
#endif

  JsonArray arr = doc.to<JsonArray>();
  
  for (int i = 0; i < MAX_NOTICES; i++) {
    if (notices[i].active) {
      JsonObject obj = arr.createNestedObject();
      obj["id"] = i;
      obj["title"] = notices[i].title;
      obj["message"] = notices[i].message;
      obj["scheduled"] = notices[i].year > 0;
      if (notices[i].year > 0) {
        char buf[25];
        sprintf(buf, "%04d-%02d-%02dT%02d:%02d", 
          notices[i].year, notices[i].month, notices[i].day,
          notices[i].hour, notices[i].minute);
        obj["datetime"] = buf;
        obj["displayed"] = notices[i].displayed;
      }
    }
  }
  
  String response;
  serializeJson(doc, response);
  server.send(200, "application/json", response);
}

void handleUpdateNotice() {
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.sendHeader("Access-Control-Allow-Methods", "POST,OPTIONS");
  server.sendHeader("Access-Control-Allow-Headers", "Content-Type");

  if (server.method() == HTTP_OPTIONS) {
    server.send(204);
    return;
  }

  String postBody = server.arg("plain");
  
#if ARDUINOJSON_VERSION_MAJOR >= 7
  JsonDocument doc;
#else
  DynamicJsonDocument doc(1024);
#endif

  DeserializationError error = deserializeJson(doc, postBody);
  if (error) {
    server.send(400, "application/json", "{\"error\":\"Invalid JSON\"}");
    return;
  }

  // Find empty slot
  int slot = -1;
  for(int i=0; i<MAX_NOTICES; i++) {
    if (!notices[i].active) {
      slot = i;
      break;
    }
  }
  
  if (slot == -1) {
    server.send(507, "application/json", "{\"error\":\"Storage full\"}");
    return;
  }

  // Fill notice
  notices[slot].title = doc["title"] | "New Notice";
  notices[slot].message = doc["message"] | "";
  notices[slot].active = true;
  notices[slot].displayed = false;
  
  // Scheduling
  if (doc["year"] | 0 > 0) {
    notices[slot].year = doc["year"];
    notices[slot].month = doc["month"];
    notices[slot].day = doc["day"];
    notices[slot].hour = doc["hour"];
    notices[slot].minute = doc["minute"];
    
    Serial.printf("[Scheduler] #%d scheduled for %04d-%02d-%02d %02d:%02d\n",
      slot, notices[slot].year, notices[slot].month, notices[slot].day,
      notices[slot].hour, notices[slot].minute);
    
    String response = "{\"status\":\"scheduled\",\"id\":" + String(slot) + ",";
    response += "\"datetime\":\"" + String(notices[slot].year) + "-" + 
                String(notices[slot].month) + "-" + String(notices[slot].day) + " " +
                String(notices[slot].hour) + ":" + String(notices[slot].minute) + "\"}";
    server.send(200, "application/json", response);
    
  } else {
    // IMMEDIATE - TRIGGER BUZZER + ANIMATION!
    notices[slot].year = 0;
    notices[slot].displayed = true;
    noticeCount++;
    currentNoticeIndex = slot;
    
    // BUZZER ON!
    triggerBuzzer();
    
    // SHOW INSTANTLY!
    showCurrentNotice();
    
    resetActivityTimer();
    
    String response = "{\"status\":\"immediate\",\"id\":" + String(slot) + "}";
    server.send(200, "application/json", response);
    
    Serial.printf("[API] Immediate notice #%d\n", slot);
  }
}

# Smart Medicine Box — Project Overview & PRD
## Improving Daily Life for Elderly Family Member

**Version:** 1.0  
**Date:** August 2026  
**Project Type:** IoT + Mobile Application (Hardware + Software)  
**Platform:** ESP32 + Flutter + Firebase  

---

## 1. Executive Summary

The **Smart Medicine Box** is an IoT-enabled medication reminder system designed to improve the daily life of elderly family members and reduce the caregiving burden on their families. The system combines a physical smart pill box (built around ESP32 microcontroller) with a companion mobile application (Flutter) that allows remote monitoring, scheduling, and emergency alerts.

### Key Value Propositions
- **For Elderly Users:** Simple, always-visible reminders with audio-visual alerts. No smartphone interaction required.
- **For Caregivers:** Remote scheduling, real-time adherence tracking, and emergency notifications via mobile app.
- **For Families:** Peace of mind through automated monitoring and instant missed-dose alerts.

---

## 2. Problem Statement (Aligned with College Brief)

### 2.1 Step 1 — Observe and Interact
Elderly individuals face significant challenges in managing daily medication:
- **Memory decline** leads to forgotten doses or double-dosing
- **Complex regimens** (multiple pills, varying times) are difficult to track
- **Isolation** means no one is physically present to remind them
- **Smartphone aversion** makes app-only solutions ineffective

Caregivers (adult children/relatives) face:
- **Guilt and anxiety** about not being physically present
- **Inconsistent communication** — calling every few hours is unsustainable
- **No visibility** into whether medications were actually taken
- **Delayed response** to emergencies due to lack of real-time awareness

### 2.2 Step 2 — Identify Caregiver Problem
> *"I can't be there every day to remind my parent to take their medicine, and I have no way to know if they actually took it or if they missed it entirely."*

**Core Pain Points:**
1. **Adherence Uncertainty** — Did they open the box? Did they take the pill?
2. **Scheduling Complexity** — Managing multiple medications across different times
3. **Emergency Blindness** — No way to know if something went wrong in real-time
4. **Communication Gap** — Sending reminders requires a phone call every time

### 2.3 Step 3 — Design Practical Solution
A **two-part system** that bridges the physical and digital worlds:
- **Physical Device:** A smart medicine box that detects when it's opened, sounds alarms for missed doses, and displays clear status messages
- **Digital Companion:** A mobile app that lets caregivers set schedules, receive alerts, and monitor adherence remotely

---

## 3. Solution Overview

### 3.1 System Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SMART MEDICINE BOX SYSTEM                         │
├─────────────────────────────┬───────────────────────────────────────────────┤
│      HARDWARE (ESP32)       │           SOFTWARE (Flutter + Firebase)       │
├─────────────────────────────┼───────────────────────────────────────────────┤
│  ┌─────────────────────┐    │    ┌─────────────────────────────────────┐    │
│  │   Medicine Box      │    │    │     Caregiver Mobile App            │    │
│  │  ┌───────────────┐  │    │    │  ┌─────────────────────────────┐    │    │
│  │  │  Lid + Magnet │  │    │    │  │  • Set Medicine Schedules   │    │    │
│  │  └───────┬───────┘  │    │    │  │  • View Adherence History   │    │    │
│  │          │          │    │    │  │  • Receive Push Alerts      │    │    │
│  │  ┌───────▼───────┐  │    │    │  │  • Send Custom Messages     │    │    │
│  │  │ Reed Switch   │──┼────┼────┼──┼──┤  • Emergency SOS Response   │    │    │
│  │  │ (GPIO 27)     │  │    │    │  │  • Multi-Patient Dashboard  │    │    │
│  │  └───────────────┘  │    │    │  └─────────────────────────────┘    │    │
│  │          │          │    │    │              │                      │    │
│  │  ┌───────▼───────┐  │    │    │              ▼                      │    │
│  │  │   ESP32       │  │    │    │    ┌─────────────────────────────┐    │    │
│  │  │  WROOM-32     │  │    │    │    │      Firebase Backend       │    │    │
│  │  │               │  │    │    │    │  ┌───────────────────────┐  │    │    │
│  │  │ • Reads RTC   │  │    │    │    │  │ Firestore Database    │  │    │    │
│  │  │ • Detects lid │  │    │    │    │  │  - Schedules          │  │    │    │
│  │  │ • Controls    │  │    │    │    │  │  - Adherence Logs     │  │    │    │
│  │  │   LEDs/Buzzer │  │    │    │    │  │  - Device Registry    │  │    │    │
│  │  │ • Updates LCD │  │    │    │    │  └───────────────────────┘  │    │    │
│  │  │ • Sends WiFi  │──┼────┼────┼────┼──┤ FCM Push Notifications    │    │    │
│  │  │   alerts      │  │    │    │    │  ┌───────────────────────┐  │    │    │
│  │  └───────────────┘  │    │    │    │  │ Cloud Functions       │  │    │    │
│  │          │          │    │    │    │  │  - Schedule Engine    │  │    │    │
│  │  ┌───────▼───────┐  │    │    │    │  │  - Alert Dispatcher   │  │    │    │
│  │  │  DS3231 RTC   │  │    │    │    │  │  - SOS Handler        │  │    │    │
│  │  │  (I2C)        │  │    │    │    │  └───────────────────────┘  │    │    │
│  │  └───────────────┘  │    │    │    └─────────────────────────────┘    │    │
│  │          │          │    │    └─────────────────────────────────────┘    │
│  │  ┌───────▼───────┐  │    │
│  │  │ 16x2 LCD I2C  │  │    │
│  │  │ (GPIO 21/22)  │  │    │
│  │  └───────────────┘  │    │
│  │  ┌───────┐ ┌───────┐│    │
│  │  │Red LED│ │Green  ││    │
│  │  │(GPIO33│ │LED    ││    │
│  │  │)      │ │(GPIO32)│    │
│  │  └───────┘ └───────┘│    │
│  │  ┌───────────────┐  │    │
│  │  │ Active Buzzer │  │    │
│  │  │  (GPIO 25)    │  │    │
│  │  └───────────────┘  │    │
│  │  ┌───────────────┐  │    │
│  │  │ Push Button   │  │    │
│  │  │ (GPIO 26)     │  │    │
│  │  │ Manual Confirm│  │    │
│  │  └───────────────┘  │    │
│  └─────────────────────┘    │
└─────────────────────────────┴───────────────────────────────────────────────┘
```

### 3.2 User Flows

#### Flow A: Normal Medication Reminder
```
1. RTC triggers scheduled time
2. LCD displays: "TIME FOR MEDICINE"
3. Green LED blinks slowly
4. User opens lid → Reed switch detects OPEN
5. Green LED turns SOLID ON
6. LCD displays: "MEDICINE TAKEN ✓"
7. ESP32 logs timestamp to Firebase
8. Caregiver app shows: "Dose taken at 8:05 AM"
```

#### Flow B: Missed Dose Alert
```
1. RTC triggers scheduled time
2. 5-minute grace period starts
3. Lid not opened within window
4. Buzzer sounds (beep pattern)
5. Red LED turns ON
6. LCD displays: "MEDICINE MISSED!"
7. ESP32 sends WiFi alert to Firebase
8. FCM pushes notification to caregiver app
9. Caregiver receives: "Mom missed her 8:00 AM dose"
```

#### Flow C: Manual Confirmation
```
1. User hears buzzer / sees red LED
2. User presses push button (GPIO 26)
3. Buzzer stops
4. Red LED turns OFF
5. Green LED turns ON
6. LCD displays: "CONFIRMED ✓"
7. Logged as "manually confirmed"
```

#### Flow D: Emergency SOS
```
1. User holds push button for 3+ seconds
2. ESP32 detects long press
3. Buzzer sounds emergency pattern
4. LCD displays: "SOS SENT!"
5. Firebase receives emergency alert
6. All linked caregivers receive push notification
7. App shows: "EMERGENCY: Mom pressed SOS button"
```

---

## 4. Hardware Architecture

### 4.1 Component List (Bill of Materials)

| # | Component | Specification | Qty | Est. Cost (₹) | Purpose |
|---|-----------|--------------|-----|---------------|---------|
| 1 | ESP32 Dev Board | WROOM-32, 30-pin | 1 | 350 | Main controller + WiFi |
| 2 | Reed Switch | Normally Open (NO) | 1 | 30 | Lid open/close detection |
| 3 | Neodymium Magnet | 10x3mm disc | 1 | 20 | Attached to lid |
| 4 | Active Buzzer | 5V, continuous tone | 1 | 40 | Audio alerts |
| 5 | Push Button | Tactile switch | 1 | 10 | Manual confirmation + SOS |
| 6 | Red LED | 5mm, 20mA | 1 | 5 | Missed dose indicator |
| 7 | Green LED | 5mm, 20mA | 1 | 5 | Taken dose indicator |
| 8 | 16x2 LCD Display | With I2C backpack (PCF8574) | 1 | 180 | Status display |
| 9 | DS3231 RTC Module | With battery backup | 1 | 120 | Accurate timekeeping |
| 10 | Resistor 220Ω | 1/4W | 3 | 3 | LED + buzzer current limiting |
| 11 | Resistor 10kΩ | 1/4W | 2 | 2 | Pull-up/pull-down |
| 12 | Breadboard | 830 tie-points | 1 | 80 | Prototyping |
| 13 | Jumper Wires | M-M, M-F, F-F assorted | 1 set | 100 | Connections |
| 14 | Plastic Box | Small pill organizer / container | 1 | 50 | Physical enclosure |
| 15 | Power Supply | 5V 2A USB adapter + cable | 1 | 150 | Power for ESP32 |
| | | | **TOTAL** | **~₹1,145** | |

### 4.2 Pin Assignment Map

```
                    ESP32 WROOM-32 (30-pin)
    ┌──────────────────────────────────────────────────┐
    │  3.3V  ──┬──  Power for sensors (RTC, LCD)     │
    │  5V    ──┼──  Power for buzzer, LCD backlight   │
    │  GND   ──┴──  Common ground rail               │
    │                                                  │
    │  GPIO 27 ───► Reed Switch (INPUT, pull-up 10k) │
    │  GPIO 26 ───► Push Button (INPUT, pull-down 10k)│
    │  GPIO 25 ───► Active Buzzer (OUTPUT)           │
    │  GPIO 33 ───► Red LED (OUTPUT, 220Ω series)    │
    │  GPIO 32 ───► Green LED (OUTPUT, 220Ω series) │
    │                                                  │
    │  GPIO 21 ───► I2C SDA ──┬──► LCD SDA           │
    │  GPIO 22 ───► I2C SCL ──┼──► LCD SCL           │
    │                         ├──► RTC SDA            │
    │                         └──► RTC SCL            │
    └──────────────────────────────────────────────────┘
```

### 4.3 Circuit Schematic Description

#### Reed Switch Circuit (GPIO 27 — Pull-Up)
```
    3.3V ────┬─────────────────────┐
             │                     │
           [10kΩ]              Reed Switch
             │                     │
             └────── GPIO 27 ──────┘
             │
            GND (via ESP32 internal)
```
- When lid CLOSED (magnet near): Switch CLOSED → GPIO 27 reads LOW
- When lid OPENED (magnet away): Switch OPEN → GPIO 27 reads HIGH (pulled up)

#### Push Button Circuit (GPIO 26 — Pull-Down)
```
    GPIO 26 ────┬────────────────────┐
                │                    │
              [10kΩ]            Push Button
                │                    │
               GND                3.3V
```
- When button NOT pressed: GPIO 26 reads LOW (pulled down)
- When button PRESSED: GPIO 26 reads HIGH (connected to 3.3V)

#### LED Circuits
```
    GPIO 33 ────[220Ω]────►|──── Red LED ──── GND
    GPIO 32 ────[220Ω]────►|──── Green LED ─── GND
```

#### Buzzer Circuit
```
    GPIO 25 ────[220Ω]────► Buzzer (+) ──── GND
```

#### I2C Bus (Shared)
```
    GPIO 21 (SDA) ────┬──── LCD SDA
                      └──── RTC SDA

    GPIO 22 (SCL) ────┬──── LCD SCL
                      └──── RTC SCL

    3.3V ─────────────┬──── LCD VCC
                      └──── RTC VCC

    GND ──────────────┬──── LCD GND
                      └──── RTC GND
```

### 4.4 Physical Enclosure Design

```
┌─────────────────────────────────────────────┐
│           FRONT PANEL (User-facing)          │
│  ┌─────────────────────────────────────┐    │
│  │      16x2 LCD DISPLAY               │    │
│  │   "TIME FOR MEDICINE"               │    │
│  └─────────────────────────────────────┘    │
│                                             │
│    [🔴 RED]        [🟢 GREEN]              │
│    MISSED         TAKEN                    │
│                                             │
│         [  PUSH BUTTON  ]                  │
│         (Confirm / SOS)                    │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │                                     │    │
│  │      MEDICINE COMPARTMENT           │    │
│  │      (Box with Hinged Lid)          │    │
│  │                                     │    │
│  │    [Magnet]────[Reed Switch]        │    │
│  │     (on lid)   (on body)            │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
                    │
         ┌──────────┴──────────┐
         │   BASE PLATE        │
         │  (Hidden underneath) │
         │  • ESP32 board       │
         │  • DS3231 RTC        │
         │  • Active Buzzer      │
         │  • Wiring & resistors│
         │  • Power input (USB) │
         └──────────────────────┘
```

**Construction Notes:**
- Base plate: Cardboard/acrylic sheet (15cm x 20cm)
- Pill box: Small plastic container hot-glued to base
- All wiring runs underneath base plate for clean appearance
- USB power cable exits from back

---

## 5. Software Architecture

### 5.1 ESP32 Firmware Stack

```
┌─────────────────────────────────────────────┐
│           Application Layer                  │
│  ┌─────────┐ ┌─────────┐ ┌───────────────┐  │
│  │ Scheduler│ │ Alert   │ │ Firebase      │  │
│  │ Engine   │ │ Manager │ │ Sync Manager  │  │
│  └────┬────┘ └────┬────┘ └───────┬───────┘  │
│       └─────────────┴─────────────┘           │
├─────────────────────────────────────────────┤
│           Service Layer                      │
│  ┌─────────┐ ┌─────────┐ ┌───────────────┐  │
│  │ RTC     │ │ Reed    │ │ WiFi/HTTP     │  │
│  │ Driver  │ │ Switch  │ │ Client        │  │
│  │ (DS3231)│ │ Handler │ │ (Firebase)    │  │
│  └─────────┘ └─────────┘ └───────────────┘  │
│  ┌─────────┐ ┌─────────┐ ┌───────────────┐  │
│  │ LCD     │ │ LED/    │ │ Button        │  │
│  │ Driver  │ │ Buzzer  │ │ Handler       │  │
│  │ (I2C)   │ │ Driver  │ │ (GPIO 26)     │  │
│  └─────────┘ └─────────┘ └───────────────┘  │
├─────────────────────────────────────────────┤
│           Hardware Abstraction               │
│  ┌─────────┐ ┌─────────┐ ┌───────────────┐  │
│  │ Wire    │ │ GPIO    │ │ WiFi          │  │
│  │ (I2C)   │ │ (digital│ │ (ESP32 WiFi)  │  │
│  │         │ │  I/O)   │ │               │  │
│  └─────────┘ └─────────┘ └───────────────┘  │
└─────────────────────────────────────────────┘
```

### 5.2 Firebase Backend Architecture

```
Firestore Collections:
┌─────────────────────────────────────────────────────────┐
│  users/{userId}                                         │
│  ├── name: "Caregiver Name"                             │
│  ├── email: "caregiver@email.com"                       │
│  ├── devices: ["device_001", "device_002"]             │
│  └── createdAt: timestamp                               │
│                                                         │
│  devices/{deviceId}                                     │
│  ├── name: "Mom's Medicine Box"                         │
│  ├── ownerId: "user_123"                                │
│  ├── status: "online"                                   │
│  ├── lastSeen: timestamp                                │
│  ├── currentScheduleId: "sched_001"                     │
│  └── wifiSSID: "HomeWiFi"                               │
│                                                         │
│  schedules/{scheduleId}                                 │
│  ├── deviceId: "device_001"                             │
│  ├── medicationName: "Blood Pressure Pill"              │
│  ├── times: ["08:00", "14:00", "20:00"]                │
│  ├── gracePeriodMinutes: 15                             │
│  ├── active: true                                       │
│  └── createdBy: "user_123"                              │
│                                                         │
│  logs/{logId}                                           │
│  ├── deviceId: "device_001"                             │
│  ├── type: "taken" | "missed" | "confirmed" | "sos"    │
│  ├── scheduledTime: "08:00"                             │
│  ├── actualTime: timestamp                              │
│  ├── medicationName: "Blood Pressure Pill"              │
│  └── notified: true                                     │
└─────────────────────────────────────────────────────────┘

Cloud Functions:
┌─────────────────────────────────────────────────────────┐
│  • onScheduleTrigger → Checks if dose window expired    │
│  • onMissedDose → Sends FCM to all linked caregivers    │
│  • onSOSAlert → Sends emergency FCM + logs incident     │
│  • onDeviceOnline → Updates lastSeen timestamp          │
│  • onNewSchedule → Pushes schedule to ESP32 via HTTP   │
└─────────────────────────────────────────────────────────┘
```

### 5.3 Flutter App Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Presentation Layer                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ HomeScreen  │ │ ScheduleScreen│ │ AlertsScreen   │   │
│  │ (Dashboard) │ │ (Set Times) │ │ (Notifications) │   │
│  └──────┬──────┘ └──────┬──────┘ └────────┬────────┘   │
│  ┌──────┴──────┐ ┌──────┴──────┐ ┌────────┴────────┐   │
│  │ DeviceScreen│ │ HistoryScreen│ │ SettingsScreen│   │
│  │ (Pair/Manage)│ │ (Adherence) │ │ (Profile)      │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                    Business Logic Layer                  │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ AuthBloc    │ │ DeviceBloc  │ │ ScheduleBloc    │   │
│  │ (Firebase   │ │ (CRUD ops)  │ │ (Time mgmt)     │   │
│  │  Auth)      │ │             │ │                 │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ AlertBloc   │ │ LogBloc     │ │ FCM Handler     │   │
│  │ (Push notif)│ │ (History)   │ │ (Background)    │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                    Data Layer                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ AuthRepo    │ │ DeviceRepo  │ │ ScheduleRepo    │   │
│  │ (Firebase   │ │ (Firestore) │ │ (Firestore)     │   │
│  │  Auth)      │ │             │ │                 │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ LogRepo     │ │ FCMService  │ │ LocalStorage    │   │
│  │ (Firestore) │ │ (Firebase   │ │ (SharedPrefs)   │   │
│  │             │ │  Messaging) │ │                 │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 5.4 API Endpoints (ESP32 ↔ Firebase)

| Endpoint | Method | Body | Purpose |
|----------|--------|------|---------|
| `/api/devices/{id}/heartbeat` | POST | `{timestamp, wifiRSSI}` | Device health check |
| `/api/devices/{id}/log` | POST | `{type, scheduledTime, actualTime}` | Log dose event |
| `/api/devices/{id}/sos` | POST | `{timestamp, location}` | Emergency alert |
| `/api/devices/{id}/schedule` | GET | — | Fetch active schedule |
| `/api/devices/{id}/acknowledge` | POST | `{logId}` | Confirm notification received |

---

## 6. Functional Requirements

### 6.1 Hardware (ESP32) Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| HW-01 | Detect lid opening via reed switch with <100ms latency | Must |
| HW-02 | Display current time and status on 16x2 LCD | Must |
| HW-03 | Sound buzzer alarm for missed doses (configurable pattern) | Must |
| HW-04 | Light red LED for missed, green LED for taken | Must |
| HW-05 | Accept manual confirmation via push button | Must |
| HW-06 | Trigger SOS alert on 3+ second button hold | Must |
| HW-07 | Maintain accurate time via DS3231 RTC (battery backup) | Must |
| HW-08 | Connect to WiFi and sync with Firebase | Must |
| HW-09 | Grace period: 5-15 minutes configurable per schedule | Should |
| HW-10 | Buzzer snooze: Press button once to silence, twice to confirm | Should |

### 6.2 Mobile App Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| APP-01 | User authentication (email/password + Google Sign-In) | Must |
| APP-02 | Pair new device via QR code or device ID | Must |
| APP-03 | Create/edit medicine schedules (name, times, days) | Must |
| APP-04 | View real-time device status (online/offline) | Must |
| APP-05 | Receive push notifications for missed doses | Must |
| APP-06 | Receive push notifications for SOS alerts | Must |
| APP-07 | View adherence history (daily/weekly/monthly) | Must |
| APP-08 | Send custom message to device LCD | Should |
| APP-09 | Support multiple devices per caregiver | Should |
| APP-10 | Export adherence report as PDF | Could |

### 6.3 Backend Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| BCK-01 | Store user profiles and device registry | Must |
| BCK-02 | Store and validate medicine schedules | Must |
| BCK-03 | Log all dose events with timestamps | Must |
| BCK-04 | Send FCM push notifications to caregivers | Must |
| BCK-05 | Handle device heartbeats and offline detection | Must |
| BCK-06 | Process SOS alerts with priority routing | Must |
| BCK-07 | Schedule engine to trigger dose windows | Should |
| BCK-08 | Analytics dashboard for adherence trends | Could |

---

## 7. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| **Performance** | ESP32 boot time < 3 seconds; App screen load < 2 seconds |
| **Reliability** | RTC battery backup ensures time accuracy during power loss |
| **Availability** | Firebase 99.9% uptime; Device reconnects WiFi automatically |
| **Security** | Firebase Auth + Firestore security rules; HTTPS only |
| **Scalability** | Backend supports 10,000+ devices; no code changes needed |
| **Usability** | Elderly user requires ZERO app interaction; all physical |
| **Maintainability** | OTA firmware updates via WiFi (optional) |
| **Cost** | Total hardware cost under ₹1,500 per unit |

---

## 8. Data Flow Diagrams

### 8.1 Dose Taken (Normal Flow)

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│   RTC    │────►│  ESP32   │────►│ Reed     │────►│ Firebase │────►│ Flutter  │
│ Triggers │     │ Scheduler│     │ Switch   │     │ Log      │     │ Push     │
│  Alarm   │     │  Engine  │     │ OPEN     │     │ Event    │     │ Confirm  │
└──────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
                      │                                │
                      ▼                                ▼
                 ┌──────────┐                    ┌──────────┐
                 │   LCD    │                    │ Firestore│
                 │ "OPEN    │                    │ logs/{id}│
                 │  BOX"    │                    │          │
                 └──────────┘                    └──────────┘
```

### 8.2 Missed Dose Alert Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  RTC     │────►│  Grace   │────►│  Buzzer  │────►│  Firebase│────►│   FCM    │
│  Alarm   │     │  Period  │     │  + Red   │     │  Alert   │     │  Push to │
│          │     │ Expires  │     │  LED ON  │     │  Missed  │     │ Caregiver│
└──────────┘     └──────────┘     └──────────┘     └──────────┘     └──────────┘
                                                                         │
                                                                         ▼
                                                                    ┌──────────┐
                                                                    │ Flutter  │
                                                                    │ Notification│
                                                                    │ "Missed!"│
                                                                    └──────────┘
```

---

## 9. Implementation Roadmap

### Phase 1: Hardware Prototype (Week 1-2)
- [ ] Assemble circuit on breadboard
- [ ] Test individual components (LCD, RTC, reed switch, buzzer, LEDs)
- [ ] Verify I2C bus sharing (LCD + RTC)
- [ ] Build physical enclosure (cardboard base + pill box)
- [ ] Test reed switch magnet alignment

### Phase 2: ESP32 Firmware (Week 2-3)
- [ ] RTC time initialization and reading
- [ ] LCD display driver and message formatting
- [ ] GPIO interrupt handlers (reed switch, button)
- [ ] Scheduler engine (alarm triggering)
- [ ] Buzzer and LED control logic
- [ ] WiFi connection manager
- [ ] HTTP client for Firebase REST API
- [ ] JSON parsing for schedule fetching
- [ ] SOS long-press detection

### Phase 3: Firebase Backend (Week 3)
- [ ] Firestore database schema setup
- [ ] Security rules configuration
- [ ] Cloud Functions deployment
- [ ] FCM push notification setup
- [ ] Device registration endpoint

### Phase 4: Flutter App (Week 3-4)
- [ ] Project setup with Firebase integration
- [ ] Authentication screens (login/register)
- [ ] Device pairing flow
- [ ] Schedule creation/management
- [ ] Dashboard with device status
- [ ] Push notification handling
- [ ] Adherence history screen

### Phase 5: Integration & Testing (Week 4-5)
- [ ] End-to-end flow testing
- [ ] WiFi reconnection handling
- [ ] Power loss recovery (RTC battery)
- [ ] Push notification reliability
- [ ] Multi-device testing
- [ ] Demo video recording

### Phase 6: Documentation & Submission (Week 5-6)
- [ ] Technical report writing
- [ ] Circuit diagrams finalization
- [ ] App screenshots and UI documentation
- [ ] Demo presentation preparation
- [ ] Project report binding

---

## 10. Testing Plan

### 10.1 Hardware Testing

| Test Case | Input | Expected Output | Pass Criteria |
|-----------|-------|-----------------|---------------|
| TC-HW-01 | Open lid | Reed switch reads HIGH | GPIO 27 = HIGH |
| TC-HW-02 | Close lid | Reed switch reads LOW | GPIO 27 = LOW |
| TC-HW-03 | Press button | GPIO 26 reads HIGH | GPIO 26 = HIGH |
| TC-HW-04 | Release button | GPIO 26 reads LOW | GPIO 26 = LOW |
| TC-HW-05 | Set alarm time | Buzzer sounds at exact time | ±5 sec accuracy |
| TC-HW-06 | Power off for 1 hour | RTC maintains correct time | Time accurate after reboot |
| TC-HW-07 | WiFi disconnect | Device attempts reconnection | Reconnects within 30 sec |

### 10.2 Software Testing

| Test Case | Input | Expected Output | Pass Criteria |
|-----------|-------|-----------------|---------------|
| TC-SW-01 | Create schedule 8:00 AM | Stored in Firestore | Document exists with correct time |
| TC-SW-02 | Missed dose at 8:00 AM | FCM received within 30 sec | Notification shows on phone |
| TC-SW-03 | SOS button 3-sec hold | Emergency FCM sent | All caregivers notified |
| TC-SW-04 | Device offline > 5 min | Status shows "Offline" | App reflects offline state |
| TC-SW-05 | New user registration | Account created | Can login successfully |

### 10.3 Integration Testing

| Test Case | Flow | Expected Result |
|-----------|------|-----------------|
| TC-INT-01 | Full dose-taken flow | All components sync; caregiver sees "Taken" |
| TC-INT-02 | Full missed-dose flow | Buzzer sounds; caregiver gets push notification |
| TC-INT-03 | Power cycle during alarm | Alarm resumes after reboot; RTC time correct |
| TC-INT-04 | Multiple caregivers | All linked users receive notifications |

---

## 11. Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WiFi connectivity issues at elderly home | High | Medium | Store schedule locally; sync when online |
| Reed switch mechanical failure | High | Low | Use quality switch; add button as backup |
| Power outage | Medium | Medium | RTC battery backup; device resumes gracefully |
| Firebase free tier limits | Medium | Low | Monitor usage; implement local caching |
| ESP32 GPIO pin shortage | Low | Low | Current design uses only 7 pins; 23 available |
| Flutter build issues | Low | Medium | Use stable channel; test on physical device |

---

## 12. Deliverables for College

### 12.1 Hardware Deliverables
1. **Working Prototype** — Assembled smart medicine box with all components
2. **Circuit Diagram** — Schematic in Cirkit Designer / Fritzing
3. **Physical Photos** — Front, back, inside, and assembled views
4. **Demo Video** — 3-5 minute walkthrough of all features

### 12.2 Software Deliverables
1. **ESP32 Source Code** — Full Arduino/PlatformIO project
2. **Flutter Source Code** — Complete app with Firebase config
3. **Firebase Project** — Live backend with Cloud Functions
4. **APK File** — Installable Android app for demo

### 12.3 Documentation Deliverables
1. **Project Report** — 50-80 pages with all sections
2. **Technical Document** — System architecture, API docs
3. **User Manual** — How to use the device and app
4. **Presentation** — 15-20 slide PPT for viva

---

## 13. Future Enhancements (Post-Project)

| Feature | Description | Complexity |
|---------|-------------|------------|
| Multi-compartment box | 7-day x 4-slot organizer with individual sensors | High |
| Weight sensor | Detect if pill was actually removed (not just lid opened) | Medium |
| Voice alerts | Recorded voice reminders instead of buzzer | Low |
| Camera module | ESP32-CAM for visual confirmation | Medium |
| GPS tracking | Location alerts for wandering elderly | Medium |
| Health vitals | Integrate heart rate / SpO2 sensors | High |
| Alexa/Google Home | Voice command integration | Medium |

---

## 14. Appendices

### Appendix A: Glossary
- **RTC** — Real-Time Clock (DS3231)
- **FCM** — Firebase Cloud Messaging (push notifications)
- **Reed Switch** — Magnetically activated switch
- **I2C** — Inter-Integrated Circuit (communication protocol)
- **GPIO** — General Purpose Input/Output

### Appendix B: References
- ESP32 Datasheet: Espressif Systems
- DS3231 Datasheet: Maxim Integrated
- Firebase Documentation: Google
- Flutter Documentation: Google

### Appendix C: Team Roles (Suggested)
| Role | Responsibility |
|------|----------------|
| Hardware Lead | Circuit design, ESP32 firmware, soldering |
| Software Lead | Flutter app, Firebase backend, API design |
| Integration Lead | End-to-end testing, bug fixing, demo prep |
| Documentation Lead | Report writing, diagrams, presentation |

---

*This PRD serves as the single source of truth for the Smart Medicine Box project. All design decisions, technical specifications, and implementation plans are documented here for reference throughout the project lifecycle.*

**Document Status:** ✅ Approved for Development  
**Next Step:** Begin Phase 1 — Hardware Prototype Assembly

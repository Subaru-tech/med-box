# 📋 Smart Digital Notice Board

A complete IoT Notice Board system built with **Flutter + Firebase + ESP32** for real-time notice management and display.

## 🏗️ Architecture

```
Flutter App (Mobile) → Firebase (Cloud) → ESP32 + OLED (Hardware)
```

- **Flutter App**: Send/manage notices from Android/iOS
- **Firebase**: Real-time cloud backend (Auth, Firestore, FCM)
- **ESP32 + OLED**: Physical display (128×64 SSD1306)

## 📁 Project Structure

```
├── lib/                    # Flutter app source code
│   ├── main.dart           # App entry point
│   ├── routes.dart         # Navigation routing
│   ├── core/               # Constants, theme, utilities
│   ├── models/             # Data models (Notice, Device, User)
│   ├── services/           # Firebase services
│   ├── repositories/       # Data access layer
│   ├── providers/          # State management (Provider)
│   ├── screens/            # 8 app screens
│   └── widgets/            # Reusable UI components
├── esp32/                  # ESP32 Arduino firmware
│   └── esp32_firmware.ino
├── firebase/               # Firebase configuration
│   └── firestore.rules
└── pubspec.yaml            # Flutter dependencies
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.16+
- Android Studio / VS Code
- Firebase account
- Arduino IDE (for ESP32)

### 1. Flutter App Setup

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### 2. Firebase Setup

1. Create project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password)
3. Enable **Cloud Firestore** 
4. Add Android app → download `google-services.json` → place in `android/app/`
5. (Optional) Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Deploy security rules from `firebase/firestore.rules`

### 3. ESP32 Hardware Setup

**Components:**
| Part | Cost |
|------|------|
| ESP32 DevKit V1 | $5-8 |
| 0.96" OLED SSD1306 | $3-5 |
| Jumper wires + breadboard | $4-6 |

**Wiring:**
```
ESP32 3V3  → OLED VCC
ESP32 GND  → OLED GND
ESP32 D21  → OLED SDA
ESP32 D22  → OLED SCL
```

**Firmware:**
1. Open `esp32/esp32_firmware.ino` in Arduino IDE
2. Install libraries: FirebaseESP32, Adafruit SSD1306, Adafruit GFX, ArduinoJson
3. Update WiFi and Firebase credentials
4. Upload to ESP32

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| Splash | Animated boot with auth check |
| Login | Email/password with "remember me" |
| Sign Up | New user registration |
| Dashboard | Device status, current notice, quick actions |
| Create Notice | Form with title, message, device selector, scheduling |
| Notice History | Searchable list with resend/delete |
| Device Management | Add/edit/remove IoT boards |
| Settings | Profile, notifications, logout |

## 🎨 Design

- **Theme**: Dark mode with blue/purple gradient accents
- **Font**: Inter (Google Fonts)
- **Colors**: Slate backgrounds, vibrant status indicators
- **Components**: Rounded cards, gradient buttons, glow effects

## 📄 License

Diploma Project — IoT & Mobile Development © 2026

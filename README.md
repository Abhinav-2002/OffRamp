# OFFRAMP

**Your evening, reclaimed.**

OFFRAMP is a production-ready Android digital wellness app built with Flutter that helps users stop evening phone scrolling through friction + environment design.

> "Willpower is a scam. Design your environment instead."

## 🎯 Philosophy

Designed for 9pm brain, not 9am brain. OFFRAMP creates gentle friction that helps you stay present during your evening hours without relying on willpower.

## ✨ Features

### 1. **Four Things System**
- Define your 4 evening priorities: Social Connection, Read/Learn, Self-care, and Win Task
- Track completion with real-time progress
- Voice input support for easy capture
- Persistent storage with Hive

### 2. **Friction Overlay**
- Intercepts real app launches using Android UsageStats API
- 30-second breathing countdown before opening distracting apps
- Shows your current Win Task to keep you focused
- Tracks resistance stats for motivation

### 3. **Win Task Timer**
- 50-minute Pomodoro-style focus timer (configurable)
- Progress ring animation with soft sage color
- Confetti celebration on completion
- Haptic feedback when done

### 4. **Human Buffer**
- Schedule contact reminders for human connection
- Choose preferred method: Call, Text, or Voice Note
- Post-contact mood tracking
- Builds social accountability

### 5. **Loop Closer + Sleep Mode**
- Voice brain dump before sleep (encrypted storage)
- "One Tiny Step" planning for tomorrow
- Sleep Mode with DND and grayscale activation
- Automatic wake-up release

### 6. **Stats & Progress**
- Weekly view with real usage data
- Urges resisted, tasks completed, connections made
- Export data as JSON
- Positive framing (no shame language)

### 7. **Animated Mascot**
- Moon-faced character with expressive animations
- States: Wave, Point, Write, Jump, Sleep, Celebrate, Think, Focus, Stop
- Custom painter with smooth 60fps animations

## 🎨 Design System

```dart
// Colors
static const Color deepNavy = Color(0xFF1A1F2E);      // Background
static const Color creamWhite = Color(0xFFF5F1E8);   // Text
static const Color warmCoral = Color(0xFFE88D7D);    // Primary action
static const Color softSage = Color(0xFF7D9D8B);     // Secondary/Progress
static const Color mutedLavender = Color(0xFF9B8FB9); // Sleep accent
```

- **Typography**: Inter font family
- **Spacing**: 24dp screen padding, 16dp card padding
- **Border Radius**: 16dp cards, 12dp buttons

## 🏗 Architecture

```
lib/
├── config/
│   └── theme.dart              # Design system
├── models/
│   ├── four_things.dart        # Hive models with adapters
│   ├── distracting_app.dart
│   ├── user_stats.dart
│   ├── user_settings.dart
│   ├── human_buffer.dart
│   └── brain_dump.dart
├── services/
│   └── hive_service.dart       # Database management
├── widgets/
│   └── mascot_widget.dart      # Animated mascot
├── features/
│   ├── onboarding/
│   │   ├── welcome_screen.dart
│   │   ├── permission_wizard.dart
│   │   ├── four_things_setup.dart
│   │   └── app_selector.dart
│   ├── dashboard/
│   │   └── home_screen.dart
│   ├── friction/
│   │   └── friction_overlay_screen.dart
│   ├── win_task/
│   │   └── timer_screen.dart
│   ├── human_buffer/
│   │   └── contact_setup.dart
│   ├── sleep/
│   │   ├── loop_closer_screen.dart
│   │   └── sleep_mode_screen.dart
│   └── stats/
│       └── stats_screen.dart
├── app_new.dart                # Main app with routing
└── main.dart                   # Entry point
```

## 🛠 Setup Instructions

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Android Studio / VS Code
- Android device or emulator (API 26+)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd offramp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (if not already generated)
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Required Permissions

The app requires the following Android permissions:

- **PACKAGE_USAGE_STATS** - Detect when distracting apps open
- **SYSTEM_ALERT_WINDOW** - Show friction overlay
- **FOREGROUND_SERVICE** - Monitor app usage in background
- **POST_NOTIFICATIONS** - Send reminders
- **READ_CONTACTS** - Select contacts for Human Buffer
- **ACCESS_NOTIFICATION_POLICY** - Enable Do Not Disturb

### Granting Permissions

1. **Usage Stats**: Settings → Apps → Special app access → Usage access → OFFRAMP → Allow
2. **Display Over Apps**: Settings → Apps → Special app access → Display over other apps → OFFRAMP → Allow
3. **Notifications**: Will be requested on first launch
4. **Contacts**: Will be requested when adding Human Buffer

## 📱 Building for Production

### Release APK

```bash
flutter build apk --release
```

### Release App Bundle

```bash
flutter build appbundle --release
```

## 🔧 Native Android Components

### MainActivity.kt
- Method channels for: permissions, app monitoring, sleep mode, timer
- Handles UsageStats, DND, grayscale, contacts

### UsageStatsService.kt
- Foreground service that monitors app launches
- Checks every 2 seconds for distracting apps
- Triggers FrictionOverlay when detected

### OfframpWidgetProvider.kt
- Home screen widget showing 4 Things
- Updates via SharedPreferences bridge from Hive

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Manual Testing Checklist

- [ ] Welcome screen centered layout
- [ ] Permission wizard opens real Android settings
- [ ] Four Things saves to Hive with voice input
- [ ] App selector shows real installed apps
- [ ] Friction overlay triggers on distracting app launch
- [ ] Timer runs with progress ring animation
- [ ] Sleep mode activates DND and grayscale
- [ ] Stats screen shows real usage data

## 🚀 Future Enhancements

- iOS support
- Apple Health / Google Fit integration
- More mascot animation states
- Custom friction durations
- Weekly/daily streak tracking

---

**OFFRAMP** - Because your evening matters.

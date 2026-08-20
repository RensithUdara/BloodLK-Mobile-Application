<div align="center">
  <img src="assets/blood-lk-logo.png" alt="BloodLK logo" width="150" />

  # 🩸 BloodLK

  **A Flutter + Firebase blood donor management app for finding eligible donors, registering donors, and sending urgent blood request notifications.**

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![License](https://img.shields.io/badge/License-Private-red?style=for-the-badge)
</div>

---

## 📌 Overview

**BloodLK** helps connect blood donors with people who urgently need blood. Donors can create an account, register their details, and receive notifications when their blood group is needed. Admins can view donor records and send targeted blood request notifications by blood type.

The project is built with **Flutter**, uses **Provider** for state management, and connects to **Firebase Authentication**, **Cloud Firestore**, **Firebase Cloud Messaging**, and **Cloud Functions**.

---

## ✨ Features

- 🧑‍💻 **Donor authentication** with Firebase Auth
- 📝 **Donor registration** with NIC, name, age, phone, city, blood group, and donation date
- 🩸 **Blood group selection** for A+, A-, B+, B-, O+, O-, AB+, and AB-
- 🔍 **Eligible donor search** by blood group and city
- 📞 **One-tap phone calls** to donors
- 💬 **SMS message support** for urgent donor contact
- 🛡️ **Admin login** for protected admin access
- 📋 **Admin donor panel** to view registered donors
- 🔔 **Push notifications** using Firebase Cloud Messaging
- 🚨 **Group notifications** for urgent blood requests
- ⏰ **Scheduled donation reminders** through Firebase Cloud Functions
- 🎨 **Custom BloodLK theme and logo**

---

## 🧱 Tech Stack

| Layer | Technology |
| --- | --- |
| 📱 App Framework | Flutter |
| 💙 Language | Dart |
| 🔄 State Management | Provider |
| 🔐 Authentication | Firebase Auth |
| 🗄️ Database | Cloud Firestore |
| 🔔 Notifications | Firebase Messaging + Flutter Local Notifications |
| ⚙️ Backend Jobs | Firebase Cloud Functions |
| ☎️ Native Actions | url_launcher |

---

## 📂 Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   └── app_routes.dart
├── core/
│   ├── config/
│   │   └── firebase_options.dart
│   ├── constants/
│   │   └── app_constants.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   └── donor.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── donor_repository.dart
│       └── notification_repository.dart
├── services/
│   ├── contact_service.dart
│   └── notification_service.dart
├── viewmodels/
│   ├── admin_view_model.dart
│   ├── donor_registration_view_model.dart
│   ├── donor_search_view_model.dart
│   └── login_view_model.dart
└── views/
    ├── admin/
    ├── auth/
    ├── donor/
    ├── home/
    └── splash/
```

---

## 🚀 Getting Started

### ✅ Prerequisites

Make sure you have these installed:

- 🐦 Flutter SDK `>=3.0.0`
- 🎯 Dart SDK `>=3.0.0 <4.0.0`
- 🔥 Firebase CLI
- 🟢 Node.js `20` for Firebase Functions
- 🤖 Android Studio or VS Code
- 📱 Android emulator, iOS simulator, or physical device

Check your Flutter setup:

```bash
flutter doctor
```

---

## 📦 Installation

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd badulla_blood_donation-main
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Install Firebase Functions dependencies

```bash
cd functions
npm install
cd ..
```

### 4. Configure Firebase

This project is already configured for the Firebase project:

```text
bloodlk-mobile-app
```

If you want to connect your own Firebase project, run:

```bash
firebase login
flutterfire configure
```

Then make sure these Firebase products are enabled:

- 🔐 Authentication
- 🗄️ Cloud Firestore
- 🔔 Cloud Messaging
- ⚙️ Cloud Functions

---

## ▶️ Run the App

Run on the selected device:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

Run on Android:

```bash
flutter run -d android
```

---

## 🧪 Run Tests

```bash
flutter test
```

Analyze the code:

```bash
flutter analyze
```

---

## 🔥 Firebase Functions

The backend functions are located in:

```text
functions/index.js
```

### Available functions

- ⏰ `scheduledBloodDonationReminder`  
  Runs every 24 hours and sends reminders to donors whose last donation date is old enough.

- 🚨 `sendGroupNotification`  
  Callable function used by the admin panel to notify donors of a selected blood group.

### Run Functions locally

```bash
cd functions
npm run serve
```

### Deploy Functions

```bash
cd functions
npm run deploy
```

Or from the project root:

```bash
firebase deploy --only functions
```

---

## 🗄️ Firestore Data Model

Donor records are stored in the `donors` collection.

```js
donors/{uid} {
  nic: string,
  name: string,
  age: number,
  phone: string,
  bloodGroup: string,
  city: string,
  lastDonationDate: timestamp,
  registeredAt: timestamp,
  fcmToken: string
}
```

---

## 🧭 App Flow

1. 🩸 User opens the app from the splash screen.
2. 🔐 Donor creates an account or signs in.
3. 📝 Donor registers personal and blood donation details.
4. 🔍 Users search for eligible donors by city and blood group.
5. 📞 Users can call or SMS matching donors.
6. 🛡️ Admin signs in to view donors.
7. 🚨 Admin sends urgent blood request notifications by blood group.

---

## 🔔 Notification Flow

```text
Admin Panel
   ↓
NotificationRepository
   ↓
Firebase Callable Function: sendGroupNotification
   ↓
Firestore donor query by blood group
   ↓
Firebase Cloud Messaging
   ↓
Donor device notification
```

Foreground notifications are handled inside:

```text
lib/services/notification_service.dart
```

---

## 🔐 Firebase Setup Notes

For production use, review and secure:

- 🔒 Firestore security rules
- 🔑 Firebase Auth admin access policy
- 📲 FCM permissions on Android and iOS
- 🧾 Cloud Functions logs and error reporting
- 🛡️ Validation for donor registration data

---

## 🛠️ Useful Commands

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test

# Analyze project
flutter analyze

# Build Android APK
flutter build apk

# Build web release
flutter build web

# Deploy Firebase Functions
firebase deploy --only functions
```

---

## 📱 Supported Platforms

The Flutter project contains platform folders for:

- 🤖 Android
- 🍎 iOS
- 🌐 Web
- 🪟 Windows
- 🍏 macOS
- 🐧 Linux

Firebase and notification behavior may require additional platform-specific configuration before production release.

---

## 🧩 Main Dependencies

```yaml
provider: ^6.1.1
intl: ^0.18.1
url_launcher: ^6.3.2
flutter_local_notifications: 17.2.3
firebase_core: 3.6.0
firebase_messaging: 15.1.3
cloud_firestore: 5.4.4
firebase_auth: 5.3.1
cloud_functions: 5.1.3
```

---

## 🤝 Contributing

Contributions are welcome. A clean workflow:

1. 🍴 Fork the project
2. 🌿 Create a feature branch
3. ✅ Run `flutter analyze` and `flutter test`
4. 📩 Open a pull request

---

## 📄 License

This project is currently marked as **private**. Add a license file if you plan to publish or distribute it.

---

## ❤️ Purpose

BloodLK was created to make blood donor discovery faster, easier, and more organized for urgent situations. Every registered donor can help save a life.

<div align="center">
  <strong>🩸 Donate blood. Save lives. ❤️</strong>
</div>

<div align="center">
  <img src="assets/blood-lk-logo.png" alt="BloodLK logo" width="140" />

  # 🩸 BloodLK

  **Donate blood. Save lives. Manage urgent donor coordination with Flutter + Firebase.**

  ![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
  ![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Status](https://img.shields.io/badge/Status-Active-red?style=for-the-badge)
</div>

---

## 📌 Overview

**BloodLK** is a donor-focused blood donation app for Sri Lanka. It helps donors save donation records, track their next eligible date, find donation centers, receive urgent request alerts, and view their past donations.

Admins get a separate protected panel for emergency requests, donor lists, group notifications, donation center management, blood summaries, eligibility checks, settings, and help guides.

---

## ✨ Main Features

### 🧑‍🦰 Donor App

- 🏠 Redesigned donor home with fixed app bar, fixed bottom navigation, dashboard tiles, and reduced spacing.
- 🖼️ Auto-sliding BloodLK banner carousel using `assets/banners/banner1.png`, `banner2.png`, and `banner3.png`.
- 🔐 Donor account creation and login with Firebase Authentication.
- 🧾 Donor profile data saved to Firestore with role `donor`.
- ➕ Add donation records with donation date, patient count, location, and custom thank-you success dialog.
- 📜 Past donations screen showing saved donation history from Firebase.
- 📅 Next eligibility screen that calculates the next donation date from the last donation date.
- ⏰ Calendar reminder action for the next eligible date.
- 🏥 Donation centers screen using Firestore `donation_center` data.
- 🔎 Search and district-wise filtering for donation centers.
- ☎️ One-tap phone action for donation center contact numbers.
- 🚨 Emergency requests screen showing admin-posted requests from Firestore.
- 🔔 Notification inbox showing Firebase notification records or a proper empty state.
- ⚙️ Donor settings, help center, FAQ, achievements, and donation tips screens.

### 🛡️ Admin Panel

- 🔐 Admin-only login using Firestore `users/{uid}.role == admin`.
- 🏠 Redesigned admin dashboard with overview stats, fixed header, bottom nav, and 9 quick-action tiles.
- 🚨 Post emergency blood requests to the `emergency_request` collection.
- 📡 View emergency request list with proper loading, empty, and error states.
- 🔔 Send group alerts to one or more selected blood groups.
- ✅ Custom confirmation dialogs before sending important alerts.
- 🧑‍🤝‍🧑 Donor management list with search and Sri Lankan district filter.
- 🏥 Donation center management for adding and viewing centers.
- 📊 Blood summary dashboard using donation records.
- 📅 Eligibility management screen.
- ⚙️ Admin settings screen for notification permission and app options.
- ❓ Admin help center with practical guidance for request, alert, center, and donor workflows.

### 🔥 Firebase Features

- 🔐 Firebase Authentication for donor and admin accounts.
- 🗄️ Cloud Firestore for donors, users, donations, centers, requests, settings, and notifications.
- 📲 Firebase Cloud Messaging for push notifications.
- ⚙️ Firebase Cloud Functions for group notification delivery and reminder workflows.
- 🧭 Role-based access:
  - `admin` users can enter the admin panel.
  - `donor` users can enter the donor app.
  - empty or non-admin roles are blocked from admin access.

---

## 🧱 Tech Stack

| Layer | Technology |
| --- | --- |
| 📱 App Framework | Flutter |
| 💙 Language | Dart |
| 🔄 State Management | Provider |
| 🔐 Authentication | Firebase Auth |
| 🗄️ Database | Cloud Firestore |
| 🔔 Push Notifications | Firebase Messaging |
| 🔕 Local Notifications | Flutter Local Notifications |
| ⚙️ Backend | Firebase Cloud Functions |
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
│   ├── constants/
│   └── theme/
├── data/
│   ├── models/
│   └── repositories/
├── services/
├── viewmodels/
└── views/
    ├── admin/
    ├── auth/
    ├── donor/
    ├── home/
    └── splash/

functions/
└── index.js

assets/
├── blood-lk-logo.png
└── banners/
    ├── banner1.png
    ├── banner2.png
    └── banner3.png
```

---

## 🚀 Getting Started

### ✅ Requirements

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

### 📦 Install Dependencies

```bash
flutter pub get
```

Install Firebase Functions dependencies:

```bash
cd functions
npm install
cd ..
```

### 🔥 Firebase Setup

This app is configured for:

```text
bloodlk-mobile-app
```

Enable these Firebase products:

- 🔐 Authentication
- 🗄️ Cloud Firestore
- 📲 Cloud Messaging
- ⚙️ Cloud Functions

If connecting a new Firebase project:

```bash
firebase login
flutterfire configure
```

---

## ▶️ Run

```bash
flutter run
```

Run on Android:

```bash
flutter run -d android
```

Run on Chrome:

```bash
flutter run -d chrome
```

---

## 🧪 Quality Checks

```bash
flutter analyze
flutter test
```

---

## 🔥 Firestore Collections

### 👤 `users/{uid}`

```js
{
  email: string,
  role: "donor" | "admin",
  updatedAt: timestamp
}
```

### 🧑‍🦰 `donors/{uid}`

```js
{
  nic: string,
  name: string,
  age: number,
  phone: string,
  bloodGroup: string,
  city: string,
  role: "donor",
  lastDonationDate: timestamp,
  registeredAt: timestamp,
  fcmToken: string
}
```

### 🩸 `donors/{uid}/donations/{donationId}`

```js
{
  donationDate: timestamp,
  patientCount: number,
  location: string,
  createdAt: timestamp
}
```

### 🚨 `emergency_request/{requestId}`

```js
{
  bloodGroup: string,
  patientName: string,
  location: string,
  contactNumber: string,
  note: string,
  status: "open",
  createdAt: timestamp
}
```

### 🏥 `donation_center/{centerId}`

```js
{
  name: string,
  contactNumber: string,
  address: string,
  district: string,
  createdAt: timestamp
}
```

### 🔔 `donors/{uid}/notifications/{notificationId}`

```js
{
  title: string,
  body: string,
  createdAt: timestamp,
  read: boolean
}
```

---

## ⚙️ Firebase Functions

Main backend file:

```text
functions/index.js
```

Available workflows:

- 🚨 `sendGroupNotification` sends urgent alerts to matching blood groups.
- ⏰ Scheduled donation reminder flow checks eligibility windows.
- 🔔 Notification records are saved so donors can view alerts in the app.

Run locally:

```bash
cd functions
npm run serve
```

Deploy:

```bash
firebase deploy --only functions
```

---

## 🔐 Admin Role Setup

Admin access is controlled through Firestore:

```text
users/{adminUid}.role = admin
```

Donors are saved with:

```text
users/{uid}.role = donor
```

Only users with role `admin` can enter the admin panel. Donor or empty roles are blocked from admin login.

---

## 🛠️ Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk
firebase deploy --only functions
```

---

## 📱 Assets

- 🩸 App logo: `assets/blood-lk-logo.png`
- 🖼️ Home banners: `assets/banners/`
- 🤖 Android launcher icons: `android/app/src/main/res/mipmap-*`

If the Android launcher icon still shows an old cached logo, uninstall the app from the emulator/device and run again.

---

## ❤️ Purpose

BloodLK is built to make blood donation coordination faster, clearer, and more organized. Every donor record, alert, and donation reminder supports one goal:

<div align="center">
  <strong>🩸 Donate Blood. Save Lives. ❤️</strong>
</div>

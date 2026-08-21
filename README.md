# BloodLK

BloodLK is a Flutter and Firebase blood donation app for donor registration, donation tracking, emergency blood requests, push notifications, and admin-side donor management.

The app has two main experiences:

- Donor app: account creation, donor profile, donation centers, add donations, past donations, eligibility countdown, emergency requests, notifications, settings, FAQ, tips, achievements, help center, and home banners.
- Admin panel: role-protected admin login, dashboard overview, post emergency requests, manage requests, donors, group alerts, donation centers, eligibility, blood summary, settings, and help center.

## Tech Stack

| Area | Technology |
| --- | --- |
| App | Flutter |
| Language | Dart |
| State management | Provider |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Push notifications | Firebase Cloud Messaging |
| Local notifications | flutter_local_notifications |
| Backend | Firebase Cloud Functions |
| Phone/SMS actions | url_launcher |

## Main Features

### Donor

- Create donor account with Firebase Auth.
- Save donor role as `donor`.
- Register donor profile with NIC, name, age, phone, city, blood group, last donation date, and FCM token.
- View fixed donor home header with auto-sliding banner carousel.
- Add donation records with date, patient count, and location.
- View past donations.
- Calculate next eligible donation date using a 150-day recovery window.
- Add eligibility reminder to calendar/device where supported.
- View emergency requests posted by admins.
- View notification inbox from Firebase.
- Search and filter donation centers by district.
- Manage donor notification settings.
- Access FAQ, tips, achievements, and help/support.

### Admin

- Admin login is allowed only for users with `users/{uid}.role == "admin"`.
- Donor or missing-role accounts cannot open the admin panel.
- Admin dashboard includes overview stats for requests, donors, donation units, and centers.
- Post emergency blood requests to Firebase.
- View open emergency requests.
- Search and filter donor records by text and district.
- Send Firebase push notifications to one or more selected blood groups.
- Add and view donation centers.
- View eligible donors based on the 150-day recovery window.
- View blood group donor summary.
- Check push permission, copy FCM token, review Firebase collections, and sign out.

## Role-Based Access

BloodLK uses a `users` collection for app roles.

### Donor user

When a donor account is created or a donor profile is saved, the app writes:

```js
users/{uid} {
  email: string,
  role: "donor",
  updatedAt: timestamp
}
```

Donor profile documents also include:

```js
donors/{uid} {
  role: "donor",
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

### Admin user

To allow an account to access the admin panel, create or update:

```js
users/{adminUid} {
  email: "admin@example.com",
  role: "admin",
  updatedAt: timestamp
}
```

Rules enforced by the app:

- `role: admin` can log in to the admin panel.
- `role: donor` cannot log in to the admin panel.
- Empty or missing role cannot log in to the admin panel.
- Admin accounts cannot sign in as donors.
- Existing donor accounts with a donor profile and missing `users` role are migrated to `role: donor` on donor sign-in.

## Firestore Collections

```text
users/{uid}
donors/{uid}
donors/{uid}/donations/{donationId}
donors/{uid}/notifications/{notificationId}
donorSettings/{uid}
emergency_request/{requestId}
donation_center/{centerId}
supportRequests/{requestId}
```

### emergency_request

```js
emergency_request/{requestId} {
  bloodGroup: string,
  patientName: string,
  location: string,
  contactNumber: string,
  note: string,
  status: "open",
  createdAt: timestamp,
  notificationSentAt: timestamp,
  notificationSuccessCount: number
}
```

### donation_center

```js
donation_center/{centerId} {
  centerName: string,
  contactNumber: string,
  address: string,
  district: string,
  createdAt: timestamp
}
```

### donations

```js
donors/{uid}/donations/{donationId} {
  donationDate: timestamp,
  patientCount: number,
  location: string,
  createdAt: timestamp
}
```

## Firebase Cloud Functions

Cloud Functions are in:

```text
functions/index.js
```

Available functions:

- `onEmergencyRequestCreated`
  - Firestore trigger for `emergency_request/{requestId}`.
  - Sends push notifications to eligible matching donors.
  - Saves notification records under each donor.

- `scheduledBloodDonationReminder`
  - Runs every 24 hours.
  - Sends reminders to donors whose recovery window is complete.

- `sendGroupNotification`
  - Callable function used by the admin Group Alerts page.
  - Sends urgent alerts to eligible donors by blood group.

## Assets

Main assets:

```text
assets/blood-lk-logo.png
assets/banners/banner1.png
assets/banners/banner2.png
assets/banners/banner3.png
```

Android launcher icons are stored in:

```text
android/app/src/main/res/mipmap-*/ic_launcher.png
```

If launcher icons do not refresh on a device, uninstall the app or run:

```bash
flutter clean
flutter pub get
flutter run
```

## Project Structure

```text
lib/
  app/
    app.dart
    app_routes.dart
  core/
    config/firebase_options.dart
    constants/app_constants.dart
    theme/app_theme.dart
  data/
    models/
    repositories/
  services/
    contact_service.dart
    notification_service.dart
  viewmodels/
  views/
    admin/
    auth/
    donor/
    home/
    splash/
functions/
  index.js
assets/
  blood-lk-logo.png
  banners/
```

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `>=3.0.0 <4.0.0`
- Firebase CLI
- Node.js for Firebase Functions
- Android Studio, VS Code, or another Flutter IDE
- Android emulator or physical Android device

Check Flutter:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
cd functions
npm install
cd ..
```

### Firebase Setup

This project is configured for Firebase services. Make sure these are enabled:

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Cloud Functions

If connecting to another Firebase project:

```bash
firebase login
flutterfire configure
```

## Run

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

## Quality Checks

Analyze:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Firebase Deploy

Run functions locally:

```bash
cd functions
npm run serve
```

Deploy functions:

```bash
firebase deploy --only functions
```

## Important Notes

- Admin access depends on the `users/{uid}.role` field.
- Firestore security rules should also enforce the same role restrictions before production.
- Push notifications require valid FCM permissions and device tokens.
- Some Firestore queries are sorted in Dart to avoid requiring composite indexes.
- Donation eligibility uses a 150-day recovery window.

## Main Dependencies

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

## Purpose

BloodLK is designed to make blood donor coordination faster and clearer for donors, hospitals, and administrators. The goal is simple: help people find eligible donors and respond quickly during urgent blood requests.

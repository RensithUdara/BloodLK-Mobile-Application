# BloodLK Admin Web

React + Firebase admin panel for the BloodLK mobile app.

## Features

- Admin role login using `users/{uid}.role == admin`
- Dashboard overview for requests, donors, donation units, and centers
- Post emergency requests to `emergency_request`
- View and close emergency requests
- Donor list with search and Sri Lankan district filter
- Group alerts for one or more blood groups using Firebase Functions
- Donation center add/list/search/filter using `donation_center`
- Eligibility view based on a 150-day recovery window
- Blood group summary
- Settings and help screens

## Run

```bash
npm install
npm run dev
```

Open:

```text
http://localhost:5173/
```

## Build

```bash
npm run build
```

## Optional Web FCM Token

To copy a browser FCM token from the Settings page, add a web push VAPID key:

```bash
VITE_FIREBASE_VAPID_KEY=your_key_here
```

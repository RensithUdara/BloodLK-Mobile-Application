# 🛡️ BloodLK Security Policy

<div align="center">
  <img src="assets/blood-lk-logo.png" alt="BloodLK logo" width="120" />

  **Security guidance for the BloodLK Flutter + Firebase blood donation app.**
</div>

---

## ✅ Supported Version

BloodLK is currently maintained as a private active project.

| Version | Status |
| --- | --- |
| `1.0.x` | ✅ Supported |
| Older local builds | ⚠️ Update recommended |

---

## 🔐 Authentication And Roles

BloodLK uses **Firebase Authentication** with Firestore role records.

Role data is stored in:

```text
users/{uid}
```

Expected role values:

```js
{
  email: string,
  role: "donor" | "admin",
  updatedAt: timestamp
}
```

Security expectations:

- 🛡️ Only users with `role: "admin"` can access the admin panel.
- 🧑‍🦰 Donor accounts are saved with `role: "donor"`.
- 🚫 Donor, empty, missing, or unknown roles must not access admin features.
- 🔁 When donor profiles are migrated, the matching `users/{uid}` role should be set to `donor`.
- 🔑 Admin roles should be assigned manually by a trusted project owner, not from the client app.

---

## 🗄️ Firestore Data Protection

Sensitive app data is stored in these collections:

| Collection | Purpose | Access Notes |
| --- | --- | --- |
| `users` | User role records | Admin role must be protected |
| `donors` | Donor profile data | Donors should read/write only their own profile |
| `donors/{uid}/donations` | Donation history | Donors should access only their own records |
| `donors/{uid}/notifications` | Notification inbox | Donors should access only their own notifications |
| `donorSettings` | Notification preferences | Donors should access only their own settings |
| `emergency_request` | Admin-posted urgent requests | Admin write, donor read |
| `donation_center` | Donation center directory | Admin write, donor read |
| `supportRequests` | Donor help requests | Donor create, admin read |

Recommended Firestore rule principles:

- ✅ Validate required fields and data types.
- ✅ Prevent clients from writing their own admin role.
- ✅ Restrict donor profile edits to `request.auth.uid`.
- ✅ Allow admins to manage emergency requests and donation centers.
- ✅ Avoid public write access to any collection.
- ✅ Keep contact numbers and donor personal data readable only where needed.

---

## 🔔 Notification Security

BloodLK uses **Firebase Cloud Messaging** for urgent request alerts and reminders.

Security expectations:

- 📲 Store FCM tokens only under the authenticated donor profile.
- 🔔 Send group alerts through Firebase Functions, not directly from the client.
- 🩸 Match urgent alerts by selected blood group before sending.
- 🧾 Save notification records to donor notification subcollections for inbox display.
- 🚫 Never expose server keys or Firebase Admin credentials in the Flutter app.

---

## ⚙️ Firebase Functions

Backend logic lives in:

```text
functions/index.js
```

Current security-sensitive workflows:

- 🚨 `sendGroupNotification`
- 🚨 emergency request notification trigger
- ⏰ scheduled donation eligibility reminders

Function safety checklist:

- ✅ Require authentication for callable admin actions.
- ✅ Verify the caller has `role: "admin"` before sending group alerts.
- ✅ Validate blood group, patient name, location, phone number, and notes.
- ✅ Avoid sending notifications to donors who disabled matching alert settings.
- ✅ Log failures without exposing donor private data.

---

## 🧪 Security Testing Checklist

Before release, verify:

- 🔐 Donor login cannot open admin panel.
- 🔐 Missing or empty role cannot open admin panel.
- 🔐 Admin login works only when `users/{uid}.role` is `admin`.
- 🧑‍🦰 Donors cannot read or edit another donor profile.
- 🩸 Donors cannot edit another donor donation history.
- 🏥 Donors cannot create or edit donation centers.
- 🚨 Donors cannot create admin emergency requests.
- 🔔 Group alerts cannot be sent from non-admin accounts.
- 📲 FCM token updates only affect the signed-in donor.

---

## 🚨 Reporting A Vulnerability

If you find a security issue, report it privately to the project owner or admin team.

Please include:

- A short summary of the issue.
- Steps to reproduce.
- Screenshots or logs if available.
- The affected screen, file, collection, or Firebase Function.
- Whether donor data, admin access, notifications, or Firestore writes are affected.

Do not create public issues containing private donor information, Firebase config secrets, admin credentials, or exploitable details.

---

## 🔑 Secret Handling

- Never commit Firebase Admin SDK private keys.
- Never commit `.env` files containing secrets.
- Keep Firebase service account files outside the app repository.
- Do not place server credentials in Flutter assets or source files.
- Rotate exposed credentials immediately if they are accidentally committed.

---

## 📱 Device And App Notes

- Android/iOS notification permissions should be requested only when needed.
- If launcher or splash assets are changed, uninstall old builds from test devices to clear cached icons.
- Production builds should use release signing keys stored outside the repository.

---

## ❤️ Safety Goal

BloodLK handles personal donor details and urgent medical coordination data. Keep the system simple, private, and role-protected so donors can help safely.

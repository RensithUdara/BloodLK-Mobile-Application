# BloodLK Google Play Release Details

## Built Release Bundle

- App bundle: `build/app/outputs/bundle/release/app-release.aab`
- Package name: `com.rensithudara.bloodlk`
- App name: `BloodLK`
- Version name: `1.0.0`
- Version code: `1`
- Target SDK: `36`
- Release signing: local upload key at `android/app/upload-keystore.jks`

Keep `android/key.properties` and `android/app/upload-keystore.jks` backed up safely. They are required for future releases signed with the same upload key.

## Main Store Listing

### App Name

BloodLK

### Short Description

Find blood donation centers, track donations, and receive urgent requests

### Full Description

BloodLK helps blood donors in Sri Lanka manage their donation journey and respond faster when urgent blood requests are posted.

Donors can create an account, save their donor profile, record past donations, track their next eligible donation date, browse donation centers, and view urgent blood requests from administrators.

Key features:

- Donor account creation and secure login
- Donor profile with blood group, city, phone, and donation details
- Donation history tracking
- Next eligibility date calculation
- Donation center search and district filtering
- One-tap contact actions for donation centers
- Emergency blood request list
- Notification inbox for donor alerts
- Help center, donation tips, settings, and achievements

BloodLK also includes an admin workflow for managing donors, posting emergency requests, sending group alerts, adding donation centers, reviewing summaries, and checking donor eligibility.

BloodLK is designed to make donor coordination faster, clearer, and more organized.

## Suggested Play Console Setup

- App category: Medical
- App type: App
- Pricing: Free
- Countries/regions: Sri Lanka first, then expand if needed
- Contains ads: No, unless you add ads later
- App access: Login required for donor/admin features; provide a test donor account to Google Play review
- Content rating: Complete the Play Console questionnaire honestly; likely suitable for general medical/health utility use if no graphic content is shown
- Target audience: Adults / general audience, depending on your actual donor eligibility rules
- News app: No
- Government app: No, unless this is officially operated by a government body

## Graphic Assets Needed

- App icon: 512 x 512 PNG, max 1024 KB
- Feature graphic: 1024 x 500 PNG or JPEG
- Phone screenshots: minimum 2, recommended 4 or more
- Screenshot format: PNG or JPEG, no alpha, minimum 320 px, maximum 3840 px
- Recommended phone screenshots: 1080 x 1920 portrait

Recommended screenshot set:

1. Donor home dashboard
2. Donor registration or profile
3. Donation centers search
4. Emergency requests
5. Next eligibility date
6. Past donations
7. Notification inbox
8. Help center or settings

## Data Safety Draft

Expected data collected:

- Personal info: name, email address, phone number, NIC, city/district
- Health and fitness info: blood group, donation dates, donation history, eligibility-related data
- App activity: notification records and app workflow data
- Device or other IDs: Firebase Cloud Messaging token and Firebase user ID

Expected purpose:

- App functionality
- Account management
- Donor matching and emergency request coordination
- Notifications and reminders
- Security and fraud prevention

Expected sharing:

- Firebase services process app data as your backend provider
- Do not mark data as sold
- Only mark external sharing if you intentionally provide data to another third party

Security notes:

- Firebase network traffic is encrypted in transit
- Firestore security rules should restrict donor/admin access before production
- Add a privacy policy URL before publishing
- Because the app supports account creation, prepare an account and data deletion process/page

## Firebase Requirement

The current local `google-services.json` was adjusted to build with the new Android package. Before publishing, create or update the Android app in Firebase Console with this exact package name:

`com.rensithudara.bloodlk`

Then download the new `google-services.json` and replace:

`android/app/google-services.json`

Re-run:

```bash
flutter build appbundle --release
```

## Release Checklist

1. Upload `build/app/outputs/bundle/release/app-release.aab` to Play Console.
2. Add store listing name, short description, and full description.
3. Upload icon, feature graphic, and screenshots.
4. Add privacy policy URL.
5. Complete Data safety.
6. Complete Content rating.
7. Complete Target audience and content.
8. Complete App access and provide test login credentials.
9. Complete Ads declaration.
10. Complete Data deletion details.
11. Run closed testing first.
12. Promote to production after review/testing.

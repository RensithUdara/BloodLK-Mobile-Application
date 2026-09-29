const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { defineSecret, defineString } = require("firebase-functions/params");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();

const RECOVERY_DAYS = 150;
const OTP_TTL_MINUTES = 5;
const OTP_RESEND_SECONDS = 45;
const OTP_MAX_ATTEMPTS = 5;
const TEXTLK_SEND_URL = "https://app.text.lk/api/v3/sms/send";
const textlkApiKey = defineSecret("TEXTLK_API_KEY");
const textlkSenderId = defineString("TEXTLK_SENDER_ID", { default: "BloodLK" });

function lastEligibleDate() {
  const date = new Date();
  date.setDate(date.getDate() - RECOVERY_DAYS);
  return date;
}

function isEligibleDonor(donor) {
  if (!donor.lastDonationDate) return true;
  const lastDonationDate = donor.lastDonationDate.toDate
    ? donor.lastDonationDate.toDate()
    : new Date(donor.lastDonationDate);
  return lastDonationDate <= lastEligibleDate();
}

function cleanToken(value) {
  return typeof value === "string" && value.trim() !== "" ? value.trim() : null;
}

function requireSignedIn(request) {
  const uid = request.auth && request.auth.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Please sign in first.");
  }
  return uid;
}

function normalizeSriLankanMobile(value) {
  const raw = typeof value === "string" ? value.trim() : "";
  let digits = raw.replace(/[^\d]/g, "");

  if (digits.startsWith("0094")) digits = digits.slice(2);
  if (digits.startsWith("0")) digits = `94${digits.slice(1)}`;
  if (digits.length === 9 && digits.startsWith("7")) digits = `94${digits}`;

  if (!/^947\d{8}$/.test(digits)) {
    throw new HttpsError(
      "invalid-argument",
      "Enter a valid Sri Lankan mobile number, for example 0771234567.",
    );
  }

  return digits;
}

function createOtp() {
  return crypto.randomInt(1000, 10000).toString();
}

function hashOtp(code, salt) {
  return crypto.createHash("sha256").update(`${salt}:${code}`).digest("hex");
}

function readTextlkConfig() {
  const apiKey = textlkApiKey.value() || process.env.TEXTLK_API_KEY;
  const senderId = textlkSenderId.value() || process.env.TEXTLK_SENDER_ID;

  if (!apiKey) {
    throw new HttpsError(
      "failed-precondition",
      "TextLK API key is not configured.",
    );
  }

  if (!senderId) {
    throw new HttpsError(
      "failed-precondition",
      "TextLK sender ID is not configured.",
    );
  }

  return { apiKey, senderId };
}

async function sendTextlkSms({ recipient, message }) {
  const { apiKey, senderId } = readTextlkConfig();
  const response = await fetch(TEXTLK_SEND_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({
      recipient,
      sender_id: senderId,
      type: "plain",
      message,
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    console.error("TextLK SMS send failed", {
      status: response.status,
      body: body.slice(0, 500),
    });
    throw new HttpsError(
      "unavailable",
      "Could not send the OTP SMS. Please try again.",
    );
  }
}

async function getEnabledSettings(uid) {
  const snapshot = await admin.firestore().collection("donorSettings").doc(uid).get();
  const settings = snapshot.data() || {};
  return {
    urgentAlerts: settings.urgentAlerts !== false,
    eligibilityReminders: settings.eligibilityReminders !== false,
    cityAlerts: settings.cityAlerts !== false,
  };
}

async function getMatchingDonors({ bloodGroup, city, settingKey }) {
  const donorSnapshot = await admin
    .firestore()
    .collection("donors")
    .where("bloodGroup", "==", bloodGroup)
    .get();

  const donors = [];
  const seen = new Set();

  for (const doc of donorSnapshot.docs) {
    const donor = doc.data();
    const token = cleanToken(donor.fcmToken);
    if (!token || seen.has(token) || !isEligibleDonor(donor)) continue;

    const settings = await getEnabledSettings(doc.id);
    if (settingKey && !settings[settingKey]) continue;
    if (
      city &&
      settings.cityAlerts &&
      donor.city &&
      donor.city.toString().toLowerCase() !== city.toLowerCase()
    ) {
      continue;
    }

    seen.add(token);
    donors.push({ uid: doc.id, token });
  }

  return donors;
}

async function sendToDonors(donors, payload) {
  if (donors.length === 0) return 0;

  let successCount = 0;
  const tokens = donors.map((donor) => donor.token);
  const chunks = [];
  for (let index = 0; index < tokens.length; index += 500) {
    chunks.push(tokens.slice(index, index + 500));
  }

  for (const chunk of chunks) {
    const response = await admin.messaging().sendEachForMulticast({
      tokens: chunk,
      notification: payload.notification,
      data: payload.data,
      android: {
        priority: "high",
        notification: {
          channelId: "blood_channel",
          priority: "high",
          defaultSound: true,
        },
      },
    });
    successCount += response.successCount;
  }

  return successCount;
}

async function saveNotificationRecords(donors, payload) {
  if (donors.length === 0) return;

  const db = admin.firestore();
  let batch = db.batch();
  let count = 0;

  for (const donor of donors) {
    const ref = db
      .collection("donors")
      .doc(donor.uid)
      .collection("notifications")
      .doc();

    batch.set(ref, {
      title: payload.notification.title,
      body: payload.notification.body,
      type: payload.data.type || "general",
      bloodGroup: payload.data.bloodGroup || null,
      requestId: payload.data.requestId || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });

    count++;
    if (count === 450) {
      await batch.commit();
      batch = db.batch();
      count = 0;
    }
  }

  if (count > 0) await batch.commit();
}

exports.onEmergencyRequestCreated = onDocumentCreated(
  "emergency_request/{requestId}",
  async (event) => {
    const request = event.data && event.data.data();
    if (!request || request.status === "closed") return null;

    const bloodGroup = request.bloodGroup;
    if (!bloodGroup) return null;

    const donors = await getMatchingDonors({
      bloodGroup,
      city: request.city || "",
      settingKey: "urgentAlerts",
    });

    const title = `Urgent ${bloodGroup} blood request`;
    const body = request.location
      ? `Emergency request at ${request.location}. Tap for contact details.`
      : "An emergency blood request was posted. Tap for contact details.";

    const payload = {
      notification: { title, body },
      data: {
        type: "emergency_request",
        requestId: event.params.requestId,
        bloodGroup: bloodGroup.toString(),
      },
    };

    await saveNotificationRecords(donors, payload);
    const successCount = await sendToDonors(donors, payload);

    await event.data.ref.set(
      {
        notificationSentAt: admin.firestore.FieldValue.serverTimestamp(),
        notificationSuccessCount: successCount,
      },
      { merge: true },
    );

    return null;
  }
);

exports.scheduledBloodDonationReminder = onSchedule("every 24 hours", async () => {
  const donorSnapshot = await admin
    .firestore()
    .collection("donors")
    .where("lastDonationDate", "<=", lastEligibleDate())
    .get();

  const donors = [];
  const seen = new Set();

  for (const doc of donorSnapshot.docs) {
    const donor = doc.data();
    const token = cleanToken(donor.fcmToken);
    if (!token || seen.has(token)) continue;

    const settings = await getEnabledSettings(doc.id);
    if (!settings.eligibilityReminders) continue;

    seen.add(token);
    donors.push({ uid: doc.id, token });
  }

  const payload = {
    notification: {
      title: "You can donate blood again",
      body: "Your donor recovery window is complete. Thank you for being ready to help.",
    },
    data: { type: "eligibility_reminder" },
  };

  await saveNotificationRecords(donors, payload);
  const successCount = await sendToDonors(donors, payload);

  console.log(`scheduledBloodDonationReminder sent ${successCount} notifications`);
  return null;
});

exports.sendGroupNotification = onCall(async (request) => {
  const bloodType = request.data && request.data.bloodType;
  const messageContent = request.data && request.data.messageContent;

  if (!bloodType) {
    throw new HttpsError("invalid-argument", "bloodType is required");
  }

  const donors = await getMatchingDonors({
    bloodGroup: bloodType,
    city: "",
    settingKey: "urgentAlerts",
  });
  const payload = {
    notification: {
      title: `Urgent ${bloodType} blood request`,
      body:
        messageContent ||
        `Urgent blood request for ${bloodType} donors. Please contact the hospital if you can help.`,
    },
    data: {
      type: "group_notification",
      bloodGroup: bloodType.toString(),
    },
  };

  await saveNotificationRecords(donors, payload);
  const successCount = await sendToDonors(donors, payload);

  if (successCount === 0) {
    return {
      success: false,
      count: 0,
      message: "No eligible donors with enabled push tokens were found.",
    };
  }

  return { success: true, count: successCount };
});

exports.sendDonorOtp = onCall({ secrets: [textlkApiKey] }, async (request) => {
  const uid = requireSignedIn(request);
  const phone = normalizeSriLankanMobile(request.data && request.data.phone);
  const db = admin.firestore();
  const ref = db.collection("donorOtpVerifications").doc(uid);
  const snapshot = await ref.get();
  const existing = snapshot.data();

  if (existing && existing.lastSentAt) {
    const lastSentAt = existing.lastSentAt.toDate
      ? existing.lastSentAt.toDate()
      : new Date(existing.lastSentAt);
    const elapsedSeconds = (Date.now() - lastSentAt.getTime()) / 1000;
    if (elapsedSeconds < OTP_RESEND_SECONDS) {
      throw new HttpsError(
        "resource-exhausted",
        `Please wait ${Math.ceil(OTP_RESEND_SECONDS - elapsedSeconds)} seconds before requesting another OTP.`,
      );
    }
  }

  const code = createOtp();
  const salt = crypto.randomBytes(16).toString("hex");
  const now = admin.firestore.Timestamp.now();
  const expiresAt = admin.firestore.Timestamp.fromMillis(
    Date.now() + OTP_TTL_MINUTES * 60 * 1000,
  );

  await sendTextlkSms({
    recipient: phone,
    message: `Your BloodLK verification OTP is ${code}. It expires in ${OTP_TTL_MINUTES} minutes.`,
  });

  await ref.set({
    phone,
    codeHash: hashOtp(code, salt),
    salt,
    attempts: 0,
    verified: false,
    createdAt: now,
    lastSentAt: now,
    expiresAt,
  });

  return { success: true, expiresInSeconds: OTP_TTL_MINUTES * 60 };
});

exports.verifyDonorOtp = onCall(async (request) => {
  const uid = requireSignedIn(request);
  const code = typeof request.data?.code === "string" ? request.data.code.trim() : "";

  if (!/^\d{4}$/.test(code)) {
    throw new HttpsError("invalid-argument", "Enter the 4-digit OTP.");
  }

  const ref = admin.firestore().collection("donorOtpVerifications").doc(uid);
  const snapshot = await ref.get();
  const verification = snapshot.data();

  if (!verification) {
    throw new HttpsError("failed-precondition", "Please request an OTP first.");
  }

  const expiresAt = verification.expiresAt && verification.expiresAt.toDate
    ? verification.expiresAt.toDate()
    : new Date(verification.expiresAt);

  if (Date.now() > expiresAt.getTime()) {
    throw new HttpsError("deadline-exceeded", "This OTP has expired. Please request a new one.");
  }

  const attempts = Number(verification.attempts || 0);
  if (attempts >= OTP_MAX_ATTEMPTS) {
    throw new HttpsError("resource-exhausted", "Too many OTP attempts. Please request a new OTP.");
  }

  const codeHash = hashOtp(code, verification.salt);
  if (codeHash !== verification.codeHash) {
    await ref.set({ attempts: attempts + 1 }, { merge: true });
    return { verified: false };
  }

  await ref.set(
    {
      verified: true,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return { verified: true };
});

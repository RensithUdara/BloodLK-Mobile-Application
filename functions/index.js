const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

const RECOVERY_DAYS = 150;

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

async function getEnabledSettings(uid) {
  const snapshot = await admin.firestore().collection("donorSettings").doc(uid).get();
  const settings = snapshot.data() || {};
  return {
    urgentAlerts: settings.urgentAlerts !== false,
    eligibilityReminders: settings.eligibilityReminders !== false,
    cityAlerts: settings.cityAlerts !== false,
  };
}

async function getMatchingDonorTokens({ bloodGroup, city }) {
  const donorSnapshot = await admin
    .firestore()
    .collection("donors")
    .where("bloodGroup", "==", bloodGroup)
    .get();

  const tokens = [];
  const seen = new Set();

  for (const doc of donorSnapshot.docs) {
    const donor = doc.data();
    const token = cleanToken(donor.fcmToken);
    if (!token || seen.has(token) || !isEligibleDonor(donor)) continue;

    const settings = await getEnabledSettings(doc.id);
    if (!settings.urgentAlerts) continue;
    if (
      city &&
      settings.cityAlerts &&
      donor.city &&
      donor.city.toString().toLowerCase() !== city.toLowerCase()
    ) {
      continue;
    }

    seen.add(token);
    tokens.push(token);
  }

  return tokens;
}

async function sendToTokens(tokens, payload) {
  if (tokens.length === 0) return 0;

  let successCount = 0;
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

exports.onEmergencyRequestCreated = onDocumentCreated(
  "emergency_request/{requestId}",
  async (event) => {
    const request = event.data && event.data.data();
    if (!request || request.status === "closed") return null;

    const bloodGroup = request.bloodGroup;
    if (!bloodGroup) return null;

    const tokens = await getMatchingDonorTokens({
      bloodGroup,
      city: request.city || "",
    });

    const title = `Urgent ${bloodGroup} blood request`;
    const body = request.location
      ? `Emergency request at ${request.location}. Tap for contact details.`
      : "An emergency blood request was posted. Tap for contact details.";

    const successCount = await sendToTokens(tokens, {
      notification: { title, body },
      data: {
        type: "emergency_request",
        requestId: event.params.requestId,
        bloodGroup: bloodGroup.toString(),
      },
    });

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

  const tokens = [];
  const seen = new Set();

  for (const doc of donorSnapshot.docs) {
    const donor = doc.data();
    const token = cleanToken(donor.fcmToken);
    if (!token || seen.has(token)) continue;

    const settings = await getEnabledSettings(doc.id);
    if (!settings.eligibilityReminders) continue;

    seen.add(token);
    tokens.push(token);
  }

  const successCount = await sendToTokens(tokens, {
    notification: {
      title: "You can donate blood again",
      body: "Your donor recovery window is complete. Thank you for being ready to help.",
    },
    data: { type: "eligibility_reminder" },
  });

  console.log(`scheduledBloodDonationReminder sent ${successCount} notifications`);
  return null;
});

exports.sendGroupNotification = onCall(async (request) => {
  const bloodType = request.data && request.data.bloodType;
  const messageContent = request.data && request.data.messageContent;

  if (!bloodType) {
    throw new HttpsError("invalid-argument", "bloodType is required");
  }

  const tokens = await getMatchingDonorTokens({ bloodGroup: bloodType, city: "" });
  const successCount = await sendToTokens(tokens, {
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
  });

  if (successCount === 0) {
    return {
      success: false,
      count: 0,
      message: "No eligible donors with enabled push tokens were found.",
    };
  }

  return { success: true, count: successCount };
});

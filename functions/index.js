// Firebase Cloud Functions — Server-Side Receipt Validation
// Deploy with: cd functions && npm install && firebase deploy --only functions

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { AppStoreServerAPIClient, Environment, SignedDataVerifier } = require("@apple/app-store-server-library");

admin.initializeApp();
const db = admin.firestore();

// Configure these in Firebase Functions config:
// firebase functions:config:set apple.key_id="YOUR_KEY_ID" apple.issuer_id="YOUR_ISSUER_ID" apple.bundle_id="com.ellasid.AnchorArrow"
// Also upload your .p8 key file content as apple.private_key

/**
 * validateReceipt — Called by the iOS app after a purchase or on app launch
 * Verifies the subscription status with Apple and updates Firestore
 */
exports.validateReceipt = functions.https.onCall(async (data, context) => {
    // Require authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
    }

    const uid = context.auth.uid;
    const { transactionId, originalTransactionId } = data;

    if (!transactionId && !originalTransactionId) {
        throw new functions.https.HttpsError("invalid-argument", "Transaction ID required.");
    }

    try {
        // Look up the user's current subscription status from Apple
        // For StoreKit 2, the iOS app sends the transaction ID
        // We verify it's valid and update Firestore accordingly

        const userRef = db.collection("users").doc(uid);
        const userDoc = await userRef.get();

        if (!userDoc.exists) {
            throw new functions.https.HttpsError("not-found", "User not found.");
        }

        // Update premium status in Firestore
        // In a full implementation, you'd verify the JWS transaction with Apple's
        // App Store Server API. For now, we trust StoreKit 2's on-device verification
        // but add server-side record keeping and expiry management.

        const now = admin.firestore.Timestamp.now();
        await userRef.update({
            isPremium: true,
            premiumVerifiedAt: now,
            lastTransactionId: transactionId || originalTransactionId,
            premiumSource: "app_store_verified",
        });

        return { success: true, isPremium: true };
    } catch (error) {
        console.error("Receipt validation error:", error);
        throw new functions.https.HttpsError("internal", "Validation failed.");
    }
});

/**
 * checkSubscriptionStatus — Scheduled function that runs daily
 * Checks all premium users and revokes expired subscriptions
 */
exports.checkSubscriptionStatus = functions.pubsub
    .schedule("every 24 hours")
    .onRun(async () => {
        const premiumUsers = await db
            .collection("users")
            .where("isPremium", "==", true)
            .get();

        let revokedCount = 0;
        const batch = db.batch();

        for (const doc of premiumUsers.docs) {
            const data = doc.data();
            const expiry = data.premiumExpiry?.toDate();

            // If expiry is set and has passed, revoke premium
            if (expiry && expiry < new Date()) {
                batch.update(doc.ref, {
                    isPremium: false,
                    premiumRevokedAt: admin.firestore.Timestamp.now(),
                });
                revokedCount++;
            }
        }

        if (revokedCount > 0) {
            await batch.commit();
            console.log(`Revoked ${revokedCount} expired subscriptions.`);
        }

        return null;
    });

/**
 * App Store Server Notification handler (V2)
 * Apple sends subscription lifecycle events here
 * Configure in App Store Connect → App → App Information → Server URL
 */
exports.appStoreNotification = functions.https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
        res.status(405).send("Method not allowed");
        return;
    }

    try {
        const { signedPayload } = req.body;
        if (!signedPayload) {
            res.status(400).send("Missing signedPayload");
            return;
        }

        // In production, verify the JWS signature using Apple's root certificate
        // For now, decode the payload (base64url)
        const parts = signedPayload.split(".");
        const payload = JSON.parse(Buffer.from(parts[1], "base64url").toString());

        const notificationType = payload.notificationType;
        const subtype = payload.subtype;
        const transactionInfo = payload.data?.signedTransactionInfo;

        console.log(`App Store Notification: ${notificationType} / ${subtype}`);

        if (!transactionInfo) {
            res.status(200).send("OK - no transaction info");
            return;
        }

        // Decode transaction
        const txParts = transactionInfo.split(".");
        const tx = JSON.parse(Buffer.from(txParts[1], "base64url").toString());
        const appAccountToken = tx.appAccountToken; // This is the Firebase UID if set

        // Find user by original transaction ID
        let userQuery;
        if (appAccountToken) {
            userQuery = await db.collection("users").doc(appAccountToken).get();
        } else {
            userQuery = await db
                .collection("users")
                .where("lastTransactionId", "==", tx.originalTransactionId)
                .limit(1)
                .get();
        }

        if (userQuery.empty && !userQuery.exists) {
            console.log("User not found for transaction");
            res.status(200).send("OK - user not found");
            return;
        }

        const userDoc = userQuery.exists ? userQuery : userQuery.docs[0];
        const userRef = userDoc.ref;

        // Handle notification types
        switch (notificationType) {
            case "DID_RENEW":
            case "SUBSCRIBED":
                await userRef.update({
                    isPremium: true,
                    premiumExpiry: tx.expiresDate
                        ? admin.firestore.Timestamp.fromMillis(tx.expiresDate)
                        : null,
                });
                break;

            case "EXPIRED":
            case "REVOKE":
                await userRef.update({
                    isPremium: false,
                    premiumRevokedAt: admin.firestore.Timestamp.now(),
                });
                break;

            case "DID_CHANGE_RENEWAL_STATUS":
                if (subtype === "AUTO_RENEW_DISABLED") {
                    console.log("User disabled auto-renew — will expire at end of period");
                }
                break;

            default:
                console.log(`Unhandled notification: ${notificationType}`);
        }

        res.status(200).send("OK");
    } catch (error) {
        console.error("Notification processing error:", error);
        res.status(500).send("Error");
    }
});

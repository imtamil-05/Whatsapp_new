const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({ maxInstances: 10 });

exports.sendChatNotification = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const messageData = event.data.data();

    const receiverId = messageData.receiverId;
    const senderName = messageData.senderName;
    const text = messageData.text;

    // Get receiver FCM token
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(receiverId)
      .get();

    if (!userDoc.exists) return;

    const token = userDoc.data().fcmToken;
    if (!token) return;

    const payload = {
      token: token,
      notification: {
        title: senderName,
        body: text,
      },
      data: {
        chatId: event.params.chatId,
        senderId: messageData.senderId,
      },
    };

    await admin.messaging().send(payload);
  }
);

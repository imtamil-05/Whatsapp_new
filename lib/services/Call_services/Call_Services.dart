import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCall(CallModel call) async {
    await _firestore
        .collection('calls')
        .doc(call.callId)
        .set(call.toMap());
    
      // 2️⃣ Mark BOTH users busy
  await _firestore.collection("users").doc(call.callerId).update({
    "isOnCall": true,
  });

  await _firestore.collection("users").doc(call.receiverId).update({
    "isOnCall": true,
  });
  }

 Future<void> updateCallStatus(String callId, String status) async {
  final doc =
      await _firestore.collection("calls").doc(callId).get();

  final data = doc.data()!;
  final callerId = data['callerId'];
  final receiverId = data['receiverId'];

  await _firestore.collection("calls").doc(callId).update({
    "status": status,
  });

  if (status == "rejected" || status == "ended" || status == "missed") {
    await _firestore.collection("users").doc(callerId).update({
      "isOnCall": false,
    });
    await _firestore.collection("users").doc(receiverId).update({
      "isOnCall": false,
    });
  }
}


  Stream<DocumentSnapshot> callStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
    });
  }

  Future<void> endCallAndCleanup(String callId) async {
  final callRef =
      FirebaseFirestore.instance.collection("calls").doc(callId);

  final snap = await callRef.get();
  if (!snap.exists) return;

  final data = snap.data()!;
  final callerId = data['callerId'];
  final receiverId = data['receiverId'];

  // End call
  await callRef.update({"status": "ended"});

  // Reset both users
  await FirebaseFirestore.instance
      .collection("users")
      .doc(callerId)
      .set({"isOnCall": false}, SetOptions(merge: true));

  await FirebaseFirestore.instance
      .collection("users")
      .doc(receiverId)
      .set({"isOnCall": false}, SetOptions(merge: true));
}


}

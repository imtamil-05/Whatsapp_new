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

  Stream<DocumentSnapshot> callStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  Future<void> acceptCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'accepted',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'rejected',
    });
  }

  Future<void> endCallAndCleanup(String callId,String duration) async {
  final callRef =
      FirebaseFirestore.instance.collection("calls").doc(callId);

  final snap = await callRef.get();
  if (!snap.exists) return;

  final data = snap.data()!;
  final callerId = data['callerId'];
  final receiverId = data['receiverId'];
  final type = data['type'] ?? 'audio';
  final startTime = data['startTime']; // Timestamp from Firestore

  final now = DateTime.now();
  
   await FirebaseFirestore.instance.collection('call_logs').add({
    'callId': callId,
    'callerId': callerId,
    'receiverId': receiverId,
    'type': type,
    'duration': duration,
    'startedAt': startTime,
    'endedAt': now,
    'timestamp': now,
  });

  // End call
  await callRef.update({"status": "ended"});

  // Reset both users
  await FirebaseFirestore.instance
      .collection("users")
      .doc(callerId)
      .update({"isOnCall": false});

  await FirebaseFirestore.instance
      .collection("users")
      .doc(receiverId)
      .update({"isOnCall": false});
  await callRef.delete();
}


}

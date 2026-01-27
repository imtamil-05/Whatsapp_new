import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';

class CallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createCall(CallModel call) async {
    await _firestore
        .collection('calls')
        .doc(call.callId)
        .set(call.toMap());
  }

  Future<void> updateCallStatus(String callId, String status) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': status,
    });
  }

  Stream<DocumentSnapshot> callStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots();
  }

  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
    });
  }
}

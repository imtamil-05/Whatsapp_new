import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> createUserIfNotExists({
    required String name,
    required String phone,
    required String fcmToken,
  }) async {
    final uid = _auth.currentUser!.uid;

    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'name': name,
        'phone': phone,
        'fcmToken': fcmToken,
        'online': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Update online + token every login
      await userRef.update({
        'online': true,
        'fcmToken': fcmToken,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<void> updateOnline(bool online) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(uid).update({
      'online': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}

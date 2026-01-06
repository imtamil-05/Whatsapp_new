import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:whatsapp_new/Screens/Home/Home_Page.dart';
import 'package:whatsapp_new/services/supabase/supabase_User_service.dart';

class OTPPage extends StatefulWidget {
  final String verificationId;
  final String phoneController;
  OTPPage({
    Key? key,
    required this.verificationId,
    required this.phoneController,
  }) : super(key: key);

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    SupabaseUserService.updateOnlineStatus(true);
  }

  @override
  void dispose() {
    SupabaseUserService.updateOnlineStatus(false);
    super.dispose();
  }

  Future<void> saveUserToFirestore() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': user.phoneNumber ?? 'User',
      'online': true,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> syncUserToSupabase(firebase_auth.User user) async {
    await supabase.Supabase.instance.client.from('users').upsert({
      'id': user.uid,
      'phone': user.phoneNumber,
      'online': true,
      'last_seen': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify your ${widget.phoneController}',
          style: TextStyle(fontSize: 20, color: Colors.teal),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Text("Enter 6 digit OTP", style: TextStyle(fontSize: 20)),
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _otpControllers[0],
                focusNode: _focusNodes[0],
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                firebase_auth.PhoneAuthCredential credential =
                    firebase_auth.PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: _otpControllers
                          .map((controller) => controller.text)
                          .join(),
                    );
                try {
                  await firebase_auth.FirebaseAuth.instance
                      .signInWithCredential(credential);
                  // Sync user to Supabase but only if login is successful
                  final user = firebase_auth.FirebaseAuth.instance.currentUser;
                  await saveUserToFirestore();

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .set({
                        'id': user.uid,
                        'name': user.displayName ?? 'User',
                        'photo': user.photoURL ?? '',
                        'online': true,
                        'lastSeen': FieldValue.serverTimestamp(),
                        'createdAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                  if (user != null) {
                    await SupabaseUserService.syncFirebaseUser(user);
                  }

                  //await firebase_auth.FirebaseAuth.instance.signInAnonymously();

                  // If success, go to Home Page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login Successful 🎉")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid OTP, please try again")),
                  );
                }
              },
              child: Text('Verify OTP', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:whatsapp_new/Screens/Auth/OTP_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  bool isloading = false;
  //final otpcontroller = TextEditingController();

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
        title: const Text(
          'Verify your Phone number',
          style: TextStyle(fontSize: 20, color: Colors.teal),
        ),
      ),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text(
                'ChatApp will send you a SMS message to verify your phone number ',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                'Enter your phone number',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isloading
                ? null
                : () async {
                    if (!phoneController.text.startsWith('+')) {
                      // phoneController.text = '+91' + phoneController.text;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Enter number with country code'),
                        ),
                      );
                      return;
                    }
                    setState(() {
                      isloading = true;
                    });
                    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: phoneController.text.trim(),
                      verificationCompleted:
                          (firebase_auth.PhoneAuthCredential credential) async {
                            await firebase_auth.FirebaseAuth.instance
                                .signInWithCredential(credential);

                            final user =
                                firebase_auth.FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await syncUserToSupabase(user);
                            }
                            if (mounted) {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                          },
                      verificationFailed:
                          (firebase_auth.FirebaseAuthException e) {
                            if (e.code == 'invalid-phone-number') {
                              print('The provided phone number is not valid.');
                            }
                          },
                      codeSent: (String verificationId, int? resendToken) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPPage(
                              verificationId: verificationId,
                              phoneController: phoneController.text,
                            ),
                          ),
                        );
                      },
                      timeout: const Duration(seconds: 120),
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                    setState(() {
                      isloading = false;
                    });
                  },
            child: isloading ? CircularProgressIndicator() : Text('Send OTP'),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whatsapp_new/Screens/Home/Chat_ListViewscreens.dart';
import 'package:whatsapp_new/Screens/get_started.dart';
import 'package:whatsapp_new/services/AppLifeCycle/App_Lifecycle_service.dart';
import 'package:whatsapp_new/services/Notification/Notification_services.dart';
import 'package:whatsapp_new/services/Storage/Storage_services.dart';

import 'firebase_options.dart';

void updateOnlineStatus(String userId, bool online) {
  FirebaseFirestore.instance.collection('users').doc(userId).update({
    "online": online,
    "lastSeen": online
        ? FieldValue.serverTimestamp()
        : FieldValue.serverTimestamp(),
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ⚡ Supabase init (ADD THIS)
  await Supabase.initialize(
    url: 'https://ykmstrwyojcazrknlaxn.supabase.co',
    anonKey: 'sb_publishable_78SlC-_VCBVADdzetxoDqQ_pNI1U0R3',
  );
  // String currentUserId = "User A";
  // await NotificationServices().saveTokenToDatabase(currentUserId);
  // NotificationServices().listenTokenRefresh(currentUserId);
  // await NotificationServices().initnotification();
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentUser == null) {
    await supabase.auth.signInAnonymously();
  }

  print("Supabase user: ${supabase.auth.currentUser?.id}");
  
  AppLifecycleService().start();
  runApp(
    ChangeNotifierProvider(
      create: (context) => StorageServices(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: GetStarted(),
      debugShowCheckedModeBanner: false,
    );
  }
}

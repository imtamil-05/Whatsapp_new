import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationServices {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin local =FlutterLocalNotificationsPlugin();

  static const String channelId="chat_app_channel";
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    channelId, // MUST be unique
    'Chat Notifications',
    description: 'Notifications for chat messages',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> initnotification() async{
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? token = await _fcm.getToken();
    print("FCM token $token");

    const AndroidInitializationSettings androidSettings=AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initsettings=InitializationSettings(android: androidSettings);
    await local.initialize(initsettings);

     await local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);


     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ShowNotification(message);

     });
     
  }

  static Future<void>requestNotificationPermission() async{
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  static Future<void> ShowNotification(RemoteMessage message) async{
    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
      channelId,
      "Chat Notifications",
      channelDescription: 'Message form a chat app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    NotificationDetails notificationDetails=NotificationDetails(android: androidNotificationDetails);
    await local.show(
       DateTime.now().millisecondsSinceEpoch ~/ 1000,
       message.notification?.title ??"No title",
       message.notification?.body ??"No body",
       notificationDetails);
  }
  
  static Future<String?> getDeviceToken() async{
    return await _fcm.getToken();
  }

   Future<void> saveTokenToDatabase(String userId) async{
    String? token = await _fcm.getToken();
    print("FCM token $token");

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        "fcmToken":token,
        "updatedAt":FieldValue.serverTimestamp(),
        },SetOptions(merge: true));
    
  }

   void listenTokenRefresh(String userId){
    _fcm.onTokenRefresh.listen((newToken)async{
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        "fcmToken":newToken,
        "updatedAt":FieldValue.serverTimestamp(),
        });
        print("FCM token refresh: $newToken");
    });
  }

  static Future<void> sendPushNotification({
    required String title,
    required String body,
    required String reciverId,
  })async{
    DocumentSnapshot userDoc=await FirebaseFirestore.instance
              .collection('users')
              .doc(reciverId)
              .get();

    if(!userDoc.exists||userDoc['fcmToken']==null){
      print("No token found for reciver $reciverId");
      return;
    }
  
  String token=userDoc['fcmToken'];
   
   const String serverkey="Your firebase server key";
   

   final response=await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
   headers: {
     "Content-Type":"application/json",
     "Authorization":"key=$serverkey"
   },
   body: jsonEncode({
    "to":token,
    "notification":{
      "title":title,
      "body":body,
      "android_channel_id":"chat_app_channel"
    },
    "data":{
      "click_action":"FLUTTER_NOTIFICATION_CLICK",
      "senderId":title,
    }
   })
   );

   print("Notification response ${response.body}");
  }


} 
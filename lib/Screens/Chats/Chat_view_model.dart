// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:whatsapp_new/Models/Message_Models.dart';
// import 'package:whatsapp_new/services/supabase/Supabase_Storage_service.dart';

// class ChatViewModel extends ChangeNotifier {
//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final  supabase = Supabase.instance.client;

  

//   String getChatRoomId(String user1, String user2) {
//     return user1.compareTo(user2) > 0 
//     ? "${user1}_$user2" 
//     : "${user2}_$user1";
//   }

//    Future<void> sendMessage({
//     required String senderId,
//     required String receiverId,
//     required String text,
//   }) async {
//     if (text.trim().isEmpty) return;

//     final chatRoomId = getChatRoomId(senderId, receiverId);

//     // Save message
//     await firestore
//         .collection('chats')
//         .doc(chatRoomId)
//         .collection('messages')
//         .add({
//       'text': text,
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'timestamp': FieldValue.serverTimestamp(),
//       'status': 'sent',
//     });
//      await firestore.collection('chats').doc(chatRoomId).set({
//       'users': [senderId, receiverId],
//       'lastMessage': text,
//       'lastMessageTime': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   // 🔄 Message stream
//   Stream<List<MessageModels>> messageStream(
//       String senderId, String receiverId) {
//     final chatRoomId = getChatRoomId(senderId, receiverId);

//     return supabase
//     .from('messages')
//     .stream(primaryKey: ['id'])
//     .eq('chat_id', chatRoomId)
//     .order('created_at', ascending: true)
//     .map((maps) => (maps as List)
//           .map((map) => MessageModels.fromMap(map))
//           .toList());
       
//   }



//   Future<List<MessageModels>> getMessages(String chatRoomId) async {
//     final snapshot = await firestore
//         .collection("chats")
//         .doc(chatRoomId)
//         .collection("messages")
//         .orderBy("timestamp", descending: false)
//         .get();

//     return snapshot.docs
//         .map((doc) => MessageModels.fromMap(doc.data()))
//         .toList();
//   }

//   Future<void> sendTextMessage(String chatRoomId, String senderId,
//       String receiverId, String text) async {
//     if (text.trim().isEmpty) return;

//     final chatRoomId = getChatRoomId(senderId, receiverId);

//     await supabase.from('messages').insert({
//       'chat_id': chatRoomId,
//       'sender_id': senderId,
//       'receiver_id': receiverId,
//       'text': text,
//       'status': 'sent',
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> sendImageMessage(
//       String chatRoomId, String senderId, String receiverId, File file) async {
//     final imageUrl = await SupabaseStorageService().uploadChatImage(file, senderId);

//     await firestore.collection("chats").doc(chatRoomId).collection("messages").add({
//       "imageUrl": imageUrl,
//       "senderId": senderId,
//       "receiverId": receiverId,
//       "timestamp": FieldValue.serverTimestamp(),
//       "status": "sent",
//       "type": "image",
//     });

//     await firestore.collection("chats").doc(chatRoomId).set({
//       "lastMessage": "📷 Photo",
//       "lastMessageTime": FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }
// }

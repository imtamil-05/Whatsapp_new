// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:whatsapp_new/Models/Message_Models.dart';
// import 'package:whatsapp_new/Screens/Chats/Chat_view_model.dart';
// import 'package:whatsapp_new/Screens/Chats/widget/message_bubble.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:whatsapp_new/utils/last_seen_formatter.dart';


// class ChatPage extends StatefulWidget {
//   final String senderId;
//   final String receiverId;
//   final String receiverName;
//   final String photo;

//   const ChatPage({
//     Key? key,
//     required this.senderId,
//     required this.receiverId,
//     required this.receiverName,
//     this.photo = "",
//   }) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController messageController = TextEditingController();
//   File? selectedImage;
  
  
//   String getChatRoomId(String user1, String user2) {
//     return user1.compareTo(user2) > 0 ? "${user1}_$user2" : "${user2}_$user1";
//   }

//   Future<void> pickAndSendImage(ImageSource source, ChatViewModel vm) async {
//     final picker = ImagePicker();
//     final pickedFile =
//         await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

//     if (pickedFile == null) return;
//     final file = File(pickedFile.path);
//     final chatRoomId = getChatRoomId(widget.senderId, widget.receiverId);
//     await vm.sendImageMessage(chatRoomId, widget.senderId, widget.receiverId, file);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatRoomId = getChatRoomId(widget.senderId, widget.receiverId);

//     return ChangeNotifierProvider(
//       create: (_) => ChatViewModel(),
//       child: Consumer<ChatViewModel>(
//         builder: (context, vm, _) {
//           return Scaffold(
//                   appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircleAvatar(
//               radius: 20,
//               backgroundImage: (widget.photo != null && widget.photo.isNotEmpty)
//                   ? (widget.photo.startsWith('http')
//                         ? NetworkImage(widget.photo) // load from URL
//                         : AssetImage(widget.photo)
//                               as ImageProvider) // local asset
//                   : AssetImage(
//                       'assets/images/whatsappbgimage.jpg',
//                     ), // default image
//             ),
//             SizedBox(width: 10),
//             Text("${widget.receiverName}", style: TextStyle(fontSize: 18)),
//               ],
//         ),

//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: Icon(Icons.video_call_outlined, size: 30),
//           ),
//           IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined)),
//           PopupMenuButton(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             itemBuilder: (context) {
//               return [
//                 // In this case, we need 5 popupmenuItems one for each option.
//                 const PopupMenuItem(child: Text('View Contact')),
//                 const PopupMenuItem(child: Text('Search')),
//                 const PopupMenuItem(child: Text('New Group')),
//                 const PopupMenuItem(child: Text('Media, links and docs')),
//                 const PopupMenuItem(child: Text('Mute Notification')),
//                 const PopupMenuItem(child: Text('Disappearing messages')),
//                 const PopupMenuItem(child: Text('More')),
//               ];
//             },
//           ),
//         ],
//       ),

//             body: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/chatbgimage.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: StreamBuilder<List<MessageModels>>(
//                       stream: vm.messageStream(widget.senderId, widget.receiverId),
                          
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData) {
//                           return Center(child: CircularProgressIndicator());
//                         }
//                         final messages = snapshot.data!;
                           

//                         if (messages.isEmpty) {
//                               return Center(child: Text('No messages yet'));
//                             }
              
//                         return ListView.builder(
//                           padding: const EdgeInsets.all(10),
//                           itemCount: messages.length,
//                           itemBuilder: (context, index) {
//                             final msg = messages[index];
//                             final isMe = msg.senderId == widget.senderId;
//                             return MessageBubble(
//                               isMe: isMe,
//                               text: msg.text,
//                               imageUrl: msg.imageUrl,
//                               status: msg.status,
//                               timestamp: msg.timestamp,
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
                  
//               SafeArea(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: messageController,
//                               minLines: 1,
//                               maxLines: 5,
//                               decoration: InputDecoration(
//                                 hintText: "Type a message",
//                                 prefixIcon: const Icon(
//                                     Icons.emoji_emotions_outlined),
//                                 suffixIcon: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.attach_file),
//                                       onPressed: () =>
//                                           pickAndSendImage(ImageSource.gallery, vm),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.camera_alt),
//                                       onPressed: () =>
//                                           pickAndSendImage(ImageSource.camera, vm),
//                                     ),
//                                   ],
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           CircleAvatar(
//                             radius: 25,
//                             backgroundColor: Colors.teal,
//                             child: IconButton(
//                               icon: const Icon(Icons.send,
//                                   color: Colors.white),
//                               onPressed: () {
//                                 vm.sendTextMessage(
//                                   chatRoomId,
//                                   widget.senderId,
//                                   widget.receiverId,
//                                   messageController.text,
//                                 );
//                                 messageController.clear();
//                               },
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
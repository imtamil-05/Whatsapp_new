//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:whatsapp_new/Screens/Chats/Chat_Page.dart';
import 'package:whatsapp_new/Screens/Chats/chat_pagee.dart';
import 'package:whatsapp_new/Screens/ContactScreen.dart';
import 'package:whatsapp_new/Widgets/ChatFilterChips/ChatFilterChips.dart';

class ChatListViewscreens extends StatefulWidget {
  final String currendUserId;
  ChatListViewscreens({Key? key, required this.currendUserId})
    : super(key: key);

  @override
  _ChatListViewscreensState createState() => _ChatListViewscreensState();
}

class _ChatListViewscreensState extends State<ChatListViewscreens> {
  // final String currendUserId = "User A";

  bool onSelected = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WhatsApp",
          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        ),
        //centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.qr_code_outlined, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.camera_alt_outlined, color: Colors.black),
          ),
          //IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,color: Colors.black,),),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (context) {
              return [
                // In this case, we need 5 popupmenuItems one for each option.
                const PopupMenuItem(child: Text('New Group')),
                const PopupMenuItem(child: Text('New Broadcast')),
                const PopupMenuItem(child: Text('Linked Devices')),
                const PopupMenuItem(child: Text('Starred Messages')),
                const PopupMenuItem(child: Text('Settings')),
              ];
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            height: 50,
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            //padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                hoverColor: Colors.teal,
                filled: true,
                fillColor: Colors.grey.shade300,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(50),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(50),
                ),
                prefixIcon: Icon(Icons.search),
                hintText: "Ask AI or Search for a chat",
              ),
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: ChatFilterChips(),
          ),
          //SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: widget.currendUserId)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final chats = snapshot.data!.docs;

                if (chats.isEmpty) {
                  return const Center(child: Text("No chats yet"));
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final users = List<String>.from(chat['users']);
                    final otherUserId = users.firstWhere(
                      (id) => id != widget.currendUserId,
                    );

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(otherUserId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return const SizedBox();

                        final user = userSnapshot.data!;
                        final name = user['name'] ?? 'User';
                        final photo = user['photo'] ?? null;

                        final lastMessage = chat['lastMessage'] ?? '';
                        final Timestamp? timeStamp = chat['lastMessageTime'];

                        final String time = timeStamp != null
                            ? DateFormat('hh:mm a').format(timeStamp.toDate())
                            : '';
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: (photo != null && photo.isNotEmpty)
                                ? (photo.startsWith('http')
                                      ? NetworkImage(photo) // load from URL
                                      : AssetImage(photo)
                                            as ImageProvider) // load from local asset
                                : null,
                            child: (photo == null || photo.isEmpty)
                                ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  chatRoomId: chat.id,
                                  currentUserId: widget.currendUserId,
                                  peerUserId: otherUserId,
                                  photo: photo,
                                  receiverName: name,
                                  senderId: widget.currendUserId,
                                  receiverId: otherUserId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContactsScreen()),
          );
        },
      ),
    );
  }
}

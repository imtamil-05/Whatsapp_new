import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Chats/chat_pagee.dart';

class ContactsScreen extends StatelessWidget {

  final String currentUserId=FirebaseAuth.instance.currentUser!.uid;

   ContactsScreen({

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select contact"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users')
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots(),
        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("No users found"));
    }

          final users = snapshot.data!.docs;

          // final users = snapshot.data!.docs
              // .where((doc) => doc.id != currentUserId)
              // .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final String name = user['name'] ?? 'Unknown Name';
              final bool online = user['online'] ?? false;

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user['name'] ?? 'Unknown Name'),
                subtitle: Text(online ? 'Online' : 'Offline',
                    style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatRoomId: '',
                        peerUserId: users[index].id,
                        currentUserId: currentUserId,
                        senderId: currentUserId,
                        receiverId: users[index].id,
                        receiverName: user['name'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Chats/chat_pagee.dart';
import 'package:whatsapp_new/Screens/Chats/widget/Full_image_view.dart';

class ViewContactScreen extends StatefulWidget {
  final String chatRoomId;
  final String peerUserId;
  final String photo;
  final String receiverName;
  final String receiverId;
  const ViewContactScreen({
    Key? key,
    required this.chatRoomId,
    required this.peerUserId,
    required this.photo,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  _ViewContactScreenState createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  Stream<QuerySnapshot> getMediaStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatRoomId)
        .collection('messages')
        .where('type', isEqualTo: 'image')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          (widget.photo != null && widget.photo.isNotEmpty)
                          ? (widget.photo.startsWith('http')
                                ? NetworkImage(widget.photo) // load from URL
                                : AssetImage(widget.photo)
                                      as ImageProvider) // local asset
                          : AssetImage(
                              'assets/images/whatsappbgimage.jpg',
                            ), // default image
                    ),
                    Text(widget.receiverName, style: TextStyle(fontSize: 20)),
                    //Text(widget.phonenumber, style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(Icons.call, "Call", () {}),
                        _actionButton(Icons.videocam, "Video Call", () {}),
                        _actionButton(Icons.search, "Search", () {}),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 10),
              
              Container(
                color: Colors.white,
                child: ListTile(
                  title: Text("About", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Hey there! I am using WhatsApp",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              Container(color: Colors.white
              ,child: Padding(
                padding: EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Media",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ),
              
              SizedBox(
                height: 250,
                child: StreamBuilder<QuerySnapshot>(
                  stream: getMediaStream(),
                  builder: (context, snapshot) {
                    /// LOADING
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
              
                    /// ERROR
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
              
                    /// EMPTY
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No media yet"));
                    }
              
                    final mediaDocs = snapshot.data!.docs;
              
                    if (mediaDocs.isEmpty) {
                      return const Center(child: Text("No media yet"));
                    }
              
                    return Container(
                      //margin: EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      color: Colors.white,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: mediaDocs.length,
                        gridDelegate:
                             SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                        itemBuilder: (context, index) {
                         final data = mediaDocs[index].data() as Map<String, dynamic>;
                        final imageUrl = data['imageUrl'];
                      
                        if (imageUrl == null || imageUrl == "") {
                          return const SizedBox();
                        }
                      
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullImageView(
                                    imageUrl: imageUrl,
                                    fromChat: true,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: imageUrl, // ⭐ SAME TAG AS CHAT PAGE
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(imageUrl, fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                               return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.broken_image, size: 40);
                                },
                              ),
                              ),
                              
                            ),
                          );
                        },
                      ),
                    );
                    
                  },
                ),
              ),
              Column(
                children: [
                  media_actions(Icons.file_copy_outlined, "Manage Storage", () {}),
                  media_actions(Icons.notifications_none_outlined, "Notifications", () {}),
                  media_actions(Icons.image, "Media visility", () {},),
                  media_actions(Icons.star,"Starred messages", () {}),
                ],
              )

             
            ],
          ),
        ),
      ),
    );
  }
}

Widget _actionButton(IconData icon, String text, VoidCallback onTap) {
  return Column(
    children: [
      CircleAvatar(
        radius: 26,
        backgroundColor: Colors.green.shade50,
        child: IconButton(
          icon: Icon(icon, color: Colors.green),
          onPressed: onTap,
        ),
      ),
      const SizedBox(height: 5),
      Text(text),
    ],
  );
}

Widget media_actions(IconData icon, String text, VoidCallback onTap) {
  return  Container(
                height: 250,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.grey.shade700),
                        const SizedBox(width: 10),
                        Text(text,style: TextStyle(
                              fontSize: 16),
                        ),
                      ],
                    )
                  ),
                ));
}
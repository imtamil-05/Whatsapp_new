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
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: SafeArea(
        child: Container(
           height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chatbgimage.jpg'),
              fit: BoxFit.cover,
            ),
          ),
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
                    _actionButton(Icons.call, "Call", () {
                          
                    }),
                    _actionButton(Icons.videocam, "Video Call", () {}),
                    _actionButton(Icons.search, "Search", () {}),
                  ]),
                SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 10),
  
                Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text("About", style: TextStyle(fontSize: 20)),
                    subtitle: Text("Hey there! I am using WhatsApp", style: TextStyle(fontSize: 15)),
                  ),
                ),
                SizedBox(height: 20),
              
                  Container(
                    color: Colors.white,
                  ),
                  const Padding(
  padding: EdgeInsets.all(12),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Text(
      "Media",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
),

SizedBox(
  height: 250,
  child: StreamBuilder<QuerySnapshot>(
    stream: getMediaStream(),
    builder: (context, snapshot) {

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      var mediaDocs = snapshot.data!.docs;

      if (mediaDocs.isEmpty) {
        return const Center(child: Text("No media yet"));
      }

      return GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaDocs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {

          String imageUrl = mediaDocs[index]['imageUrl'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullImageView(imageUrl: imageUrl),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      );
    },
  ),
),

          
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


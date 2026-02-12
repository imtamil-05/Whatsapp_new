import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Chats/chat_pagee.dart';

class ViewContactScreen extends StatefulWidget {
  final String peerUserId;
  final String photo;
  final String receiverName;
  final String receiverId;
  const ViewContactScreen({
    Key? key,
    required this.peerUserId,
    required this.photo,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  _ViewContactScreenState createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Center(child: Column(
        children: [
          Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    
                      IconButton(onPressed: (){}, icon:Icon(Icons.call),color: Colors.teal,  tooltip: "Call",),
                      IconButton(onPressed: (){}, icon:Icon(Icons.video_call_outlined),color: Colors.teal,  tooltip: "Video Call",),
                      IconButton(onPressed: (){}, icon:Icon(Icons.search),color: Colors.teal,  tooltip: "Search",),
                    ])
                ],
              ),
            ),
        ],
      ),),
    );
  }
}

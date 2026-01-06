import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_new/services/supabase/Supabase_Storage_service.dart';
enum PreviewType { status,chat }
class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final PreviewType type;
  final Function(String caption)? onsend;

  
  final String? userName;
  final String? photo;

  final String? chatRoomId;
  final String? senderId;
  final String? receiverId;

  const ImagePreviewScreen({ 
    Key? key,
    required this.imageFile,
    required this.type,
    this.onsend,

  
    this.userName,
    this.photo,

    this.chatRoomId,
    required this.senderId,
    this.receiverId, 
   }) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final captionController = TextEditingController();
  bool uploading = false;
  bool sending = false;

    void sendImage() async {
     if (sending) return;

    setState(() => sending = true);

    try {
      await widget.onsend?.call(captionController.text.trim());
    } catch (e) {
      debugPrint("Send error: $e");
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> onSend() async {
    if (uploading) return;
    setState(() {
      uploading = true;
    });

   

 
    final imageUrl= await SupabaseStorageService().uploadChatOrStatusImage(file: widget.imageFile, userId: widget.senderId!, folder: widget.type == PreviewType.chat ? 'chats' : 'status',);
    
    if (widget.type == PreviewType.status) {
    await FirebaseFirestore.instance.collection('status').add({
      'userId': widget.senderId,
      'userName': widget.userName,
      'userPhoto': widget.photo,
      'imageUrl': imageUrl,
      'caption': captionController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(
        DateTime.now().add(Duration(hours: 24)),
      ),
    });
    } 
    if (widget.type == PreviewType.chat) {
      //  if (widget.chatRoomId == null) {
      //     throw Exception("chatRoomId is null");
      //   }

      await FirebaseFirestore.instance.collection('chats').doc(widget.chatRoomId).collection('messages').add({
        "imageUrl": imageUrl,
        "caption": captionController.text.trim(),
        "senderId": widget.senderId,
        "receiverId": widget.receiverId,
        "timestamp": FieldValue.serverTimestamp(),
        "status": "sent",
        "type": "image",
        "isDeletedForEveryone": false,
        "deletedFor": [],
      });
      await FirebaseFirestore.instance.collection("chats").doc(widget.chatRoomId).set({
        "lastMessage": "📷 Photo",
        "lastMessageTime": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
  
 
  

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Image.file(
            widget.imageFile,
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,       
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: captionController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Add a caption",
                      hintStyle: TextStyle(color: Colors.white),
                      border: InputBorder.none,
                    ),
                  ),
                ),
               SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                   IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () => sendImage(),
                  ),
                ),
              ],
            ),
           ),
        ],
      ),
    );
  }
}

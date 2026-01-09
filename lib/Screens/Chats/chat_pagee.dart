import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as supabase;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whatsapp_new/Models/Message_Models.dart';
import 'package:whatsapp_new/Screens/Chats/widget/message_bubble.dart';
import 'package:whatsapp_new/Widgets/Image_preview_screen.dart';
import 'package:whatsapp_new/services/supabase/Supabase_Storage_service.dart.';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:whatsapp_new/utils/last_seen_formatter.dart';

class ChatPage extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  late String photo;
  late dynamic time;
  final String chatRoomId;
  final String currentUserId;
  final String peerUserId;

  ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.currentUserId,
    required this.peerUserId,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    this.photo = "",
    this.time = "",
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Chatmessagecontroller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  File? selectedImage;
  bool isUploading = false;
  double uploadProgress = 0.0;
  Map<String, dynamic>? user;
  String? replyMessage;
  String? replyMessageId;
  final Map<String, GlobalKey> messageKeys = {};
  String? highlightedMessageId;

  void showDeleteDialog(
    BuildContext context,
    String messageId,
    String chatRoomId,
    bool isMe,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete message?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'This message will be deleted.',
            style: TextStyle(fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
          actions: [
            // CANCEL
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),

            // DELETE FOR ME
            TextButton(
              onPressed: () {
                deleteForMe(chatRoomId, messageId);
                Navigator.pop(context);
              },
              child: const Text('DELETE FOR ME'),
            ),

            // DELETE FOR EVERYONE (only sender)
            if (isMe)
              TextButton(
                onPressed: () {
                  deleteForEveryone(chatRoomId, messageId);
                  Navigator.pop(context);
                },
                child: const Text(
                  'DELETE FOR EVERYONE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> deleteForEveryone(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'isDeletedForEveryone': true,
          'text': 'This message was deleted',
          'type': 'deleted',
        });
  }

  Future<void> deleteForMe(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'deletedFor': FieldValue.arrayUnion([widget.senderId]),
        });
  }

  @override
  Future<void> loadUser() async {
    final data = await Supabase.instance.client
        .from('users')
        .select()
        .eq('id', widget.receiverId)
        .single();

    setState(() {
      user = data;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> pickAndSendImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(
          receiverId: widget.peerUserId,
          chatRoomId: widget.chatRoomId,
          senderId: widget.currentUserId,
          imageFile: File(pickedFile.path),
          type: PreviewType.chat,
          onsend: (caption) async {
            await sendImage(File(pickedFile.path), caption);
          },
        ),
      ),
    );
  }

  Future<void> sendImage(File file, String caption) async {
    final chatRoomId = getchatRoomId(widget.senderId, widget.receiverId);

    // 1️⃣ Upload image
    final imageUrl = await SupabaseStorageService().uploadChatOrStatusImage(
      file: file,
      userId: widget.senderId,
      folder: 'chats',
    );

    // 2️⃣ Save message in Firestore
    await firebaseFirestore
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .add({
          "imageUrl": imageUrl,
          "text": caption,
          "senderId": widget.senderId,
          "receiverId": widget.receiverId,
          "timestamp": FieldValue.serverTimestamp(),
          "status": "sent",
          "type": "image",
          "deletedFor": [],
          "isDeletedForEveryone": false,
        });

    // 3️⃣ Update chat list
    await firebaseFirestore.collection("chats").doc(chatRoomId).set({
      "lastMessage": "📷 Photo",
      "lastMessageTime": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void markMessagesAsRead(String chatId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: widget.senderId)
        .where('status', isNotEqualTo: 'read')
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'status': 'read'});
          }
        });
  }

  String getchatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }

  Future<void> sendMessage() async {
    if (Chatmessagecontroller.text.trim().isEmpty) return;

    String chatRoomId = getchatRoomId(widget.senderId, widget.receiverId);

    await firebaseFirestore
        .collection("chats")
        .doc(chatRoomId)
        .collection("messages")
        .add({
          "text": Chatmessagecontroller.text,
          "senderId": widget.senderId,
          "receiverId": widget.receiverId,
          "timestamp": FieldValue.serverTimestamp(),
          "createdAt": DateTime.now().toIso8601String(),
          "status": "sent",
          "type": "text",
          "deletedFor": [],
          "isDeletedForEveryone": false,
          'replyTo': replyMessage,
          'replyToId': replyMessageId,
          'type': 'text',
        });

    setState(() {
      replyMessage = null;
      replyMessageId = null;
    });
    await firebaseFirestore.collection("chats").doc(chatRoomId).set({
      "users": [widget.senderId, widget.receiverId],
      "lastMessage": Chatmessagecontroller.text,
      "lastMessageTime": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    Chatmessagecontroller.clear();
  }

  Icon getStatusIcon(String status) {
    if (status == 'sent') {
      return const Icon(Icons.check, size: 16, color: Colors.grey);
    } else if (status == 'delivered') {
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    } else {
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    }
  }

  @override
  void initState() {
    super.initState();
    final chatId = getchatRoomId(widget.senderId, widget.receiverId);
    markMessagesAsRead(chatId);
    loadUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onReplyMessage(String message, String messageId) {
    setState(() {
      replyMessage = message;
      replyMessageId = messageId;
    });
  }

  void scrollToMessage(String messageId) {
  final key = messageKeys[messageId];
  if (key == null) return;

  final context = key.currentContext;
  if (context == null) return;

  Scrollable.ensureVisible(
    context,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  setState(() => highlightedMessageId = messageId);

  Future.delayed(const Duration(seconds: 2), () {
    setState(() => highlightedMessageId = null);
  });
}


  @override
  Widget build(BuildContext context) {
    String chatRoomId = getchatRoomId(widget.senderId, widget.receiverId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (widget.photo != null && widget.photo.isNotEmpty)
                  ? (widget.photo.startsWith('http')
                        ? NetworkImage(widget.photo) // load from URL
                        : AssetImage(widget.photo)
                              as ImageProvider) // local asset
                  : AssetImage(
                      'assets/images/whatsappbgimage.jpg',
                    ), // default image
            ),
            SizedBox(width: 10),
            Column(
              children: [
                Text("${widget.receiverName}", style: TextStyle(fontSize: 18)),

                // Text(
                //   user == null
                //       ? user!['is_typing'] == true
                //         ? 'typing...'
                //         : user!['online'] == true
                //    ? 'online'
                //    : formatLastSeen(user!['last_seen'])
                //       : '',
                //   style: TextStyle(fontSize: 10),
                // ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.videocam_outlined, size: 30),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.call_outlined)),
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (context) {
              return [
                // In this case, we need 5 popupmenuItems one for each option.
                const PopupMenuItem(child: Text('View Contact')),
                const PopupMenuItem(child: Text('Search')),
                const PopupMenuItem(child: Text('New Group')),
                const PopupMenuItem(child: Text('Media, links and docs')),
                const PopupMenuItem(child: Text('Mute Notification')),
                const PopupMenuItem(child: Text('Disappearing messages')),
                const PopupMenuItem(child: Text('More')),
              ];
            },
          ),
        ],
      ),
      // backgroundColor: Colors.teal,
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firebaseFirestore
                      .collection("chats")
                      .doc(chatRoomId)
                      .collection("messages")
                      .orderBy("timestamp", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No messages'));
                    }

                    final messages = snapshot.data!.docs
                        .map(
                          (doc) => MessageModels.fromMap(
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList();

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final message = doc.data() as Map<String, dynamic>;

                        final deletedFor = List<String>.from(
                          message['deletedFor'] ?? [],
                        );

                        if (deletedFor.contains(widget.senderId)) {
                          return const SizedBox();
                        }

                        if (message['isDeletedForEveryone'] == true) {
                          return Center(
                            child: Text(
                              'This message was deleted',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }

                        final messageId = doc.id;
                        messageKeys.putIfAbsent(messageId, () => GlobalKey());

                        final isMe = message['senderId'] == widget.senderId;
                        final Timestamp? timeStamp = message['timestamp'];
                        final String messageTime = timeStamp != null
                            ? DateFormat('hh:mm a').format(timeStamp.toDate())
                            : '';
                        if (message['type'] == 'image') {
                          return Dismissible(
                            key: ValueKey(doc.id),
                            direction: DismissDirection.startToEnd,
                            confirmDismiss: (direction) async {
                              onReplyMessage(
                                message['type'] == 'image'
                                    ? '📷 Photo'
                                    : message['text'],
                                doc.id,
                              );
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.red,
                              child: const Icon(
                                Icons.reply,
                                color: Colors.white,
                              ),
                            ),
                            child: GestureDetector(
                              onLongPress: () {
                                showDeleteDialog(
                                  context,
                                  doc.id,
                                  chatRoomId,
                                  message['senderId'] == widget.senderId,
                                );
                              },
                              child: Container(
                                key: messageKeys[messageId],
                                color:highlightedMessageId==messageId?Colors.teal.withOpacity(0.2):Colors.transparent,
                                child: MessageBubble(
                                  onReplyTap: () {
                                  scrollToMessage(doc.id);
                                },
                                  replyText: message['replyTo'],
                                  isMe: message['senderId'] == widget.senderId,
                                  text: message['text'],
                                  imageUrl: message['imageUrl'],
                                  status: message['status'] ?? 'sent',
                                  timestamp: message['timestamp']?.toDate(),
                                  isDeletedForEveryone:
                                      message['isDeletedForEveryone'] ?? false,
                                ),
                              ),
                            ),
                          );
                        }

                        return Dismissible(
                          key: ValueKey(doc.id),
                          direction: DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            onReplyMessage(
                              message['type'] == 'image'
                                  ? '📷 Photo'
                                  : message['text'],
                              doc.id,
                            );
                            return false;
                          },
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            color: Colors.grey.shade300.withOpacity(0.5),
                            child: const Icon(Icons.reply, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onLongPress: () {
                              showDeleteDialog(
                                context,
                                doc.id,
                                chatRoomId,
                                isMe,
                              );
                            },

                            child: Container(
                              key: messageKeys[messageId],
                              color:highlightedMessageId==messageId?Colors.teal.withOpacity(0.2):Colors.transparent,
                              child: MessageBubble(
                                onReplyTap: () {
                                  scrollToMessage(doc.id);
                                },
                                replyText: message['replyTo'],
                                isMe: isMe,
                                text: message['text'],
                                imageUrl: null,
                                status: message['status'] ?? 'sent',
                                timestamp: message['timestamp']?.toDate(),
                                isDeletedForEveryone:
                                    message['isDeletedForEveryone'] ?? false,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    if (replyMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Replying to",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    replyMessage!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  replyMessage = null;
                                  replyMessageId = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        if (selectedImage != null)
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedImage = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                        Expanded(
                          child: TextField(
                            controller: Chatmessagecontroller,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              isDense: true,
                              isCollapsed: true,
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.emoji_emotions_outlined,
                                size: 20,
                                color: Colors.grey,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      pickAndSendImage(ImageSource.gallery);
                                    },
                                    icon: Icon(
                                      Icons.attach_file,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      pickAndSendImage(ImageSource.camera);
                                    },
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.teal,
                          child: IconButton(
                            onPressed: () async {
                              if (Chatmessagecontroller.text.trim().isEmpty)
                                return;

                              await sendMessage(); // 🔹 send message to Firestore
                              Chatmessagecontroller.clear(); // 🔹 clear input box
                            },
                            icon: Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModels {
  final String senderId;
  final String receiverId;
  final String? text;
  final String? imageUrl;
  final String status;
  final DateTime? timestamp;
  

  MessageModels({
    required this.senderId,
    required this.receiverId,
    this.text,
    this.imageUrl,
    required this.status,
    this.timestamp,
    
  });

  factory MessageModels.fromMap(Map<String, dynamic> map) {
    return MessageModels(
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId']??'',
      text: map['text'],
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'sent',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      
    );
  }
}

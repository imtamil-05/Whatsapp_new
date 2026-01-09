import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String? text;
  final String? imageUrl;
  final String status;
  final DateTime? timestamp;
  final bool isDeletedForEveryone;
  final String? replyText;
  final VoidCallback? onReplyTap;

  const MessageBubble({
    super.key,
    required this.isMe,
    this.text,
    this.imageUrl,
    required this.status,
    this.timestamp,
    required this.isDeletedForEveryone,
    this.replyText,
    this.onReplyTap,
  });

  Icon getStatusIcon(String status) {
    if (status == 'sent') {
      return const Icon(Icons.check, size: 16, color: Colors.grey);
    } else if (status == 'delivered') {
      return const Icon(Icons.done_all, size: 16, color: Colors.grey);
    } else {
      return const Icon(Icons.done_all, size: 16, color: Colors.cyan);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isDeletedForEveryone) {
      return DeletedMessageBubble(isMe: isMe);
    }

    String messageTime = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp!)
        : '';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isMe ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (replyText != null)
               GestureDetector(
                onTap: onReplyTap,
                child: replyBoxUI(
                    context
                )),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl!, width: 200, fit: BoxFit.cover),
              ),
              if (text != null && text!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text!,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    messageTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  if (isMe) const SizedBox(width: 4),
                  if (isMe) getStatusIcon(status),
                ],
              ),
            ],
          ),
          // Stack(
          //   children: [
          //     Image.network(imageUrl!, width: 200, fit: BoxFit.cover),
          //     Positioned(
          //       bottom: 0,
          //       right: 0,
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Text(
          //             messageTime,
          //             style: TextStyle(
          //               fontSize: 10,
          //               color: isMe ? Colors.white : Colors.black,
          //             ),
          //           ),
          //           if (isMe) const SizedBox(width: 4),
          //           if (isMe) getStatusIcon(status),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (replyText != null)
                  GestureDetector(onTap: onReplyTap, child: replyBoxUI(context)),

                Text(
                  text ?? '',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      messageTime,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color.fromARGB(255, 71, 62, 62),
                      ),
                    ),
                  ],
                ),
                if (isMe) ...[const SizedBox(width: 4), getStatusIcon(status)],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget replyBoxUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            color: isMe ? Colors.white : Colors.teal,
          ),
          const SizedBox(width: 6),
          Text(
            replyText!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class DeletedMessageBubble extends StatelessWidget {
  final bool isMe;

  const DeletedMessageBubble({super.key, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'This message was deleted',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}

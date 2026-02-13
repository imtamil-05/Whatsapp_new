import 'package:flutter/material.dart';

class FullImageView extends StatelessWidget {
  final String imageUrl;

  /// if true → opens from chat bubble (no heavy UI)
  final bool fromChat;

  /// optional title (used in gallery)
  final String? title;

  const FullImageView({
    super.key,
    required this.imageUrl,
    this.fromChat = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // Hide AppBar for chat preview style
      appBar: fromChat
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(title ?? '', style: const TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {},
                ),
              ],
            ),

      body: GestureDetector(
        onTap: fromChat ? () => Navigator.pop(context) : null,
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}

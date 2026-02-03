import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Call/audio_call_screen.dart';
import 'package:whatsapp_new/Screens/Call/video_call_screen.dart';
import 'package:whatsapp_new/services/Call_services/Call_Services.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';

class IncomingCallScreen extends StatefulWidget {
  final CallModel call;

  const IncomingCallScreen({super.key, required this.call});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  

  @override
  void initState() {
    super.initState();
      Future.delayed(const Duration(seconds: 30), () async {
    final snap = await FirebaseFirestore.instance
        .collection("calls")
        .doc(widget.call.callId)
        .get();

    if (snap.exists && snap['status'] == "calling") {
      await CallService().endCallAndCleanup(widget.call.callId);
      if (mounted) Navigator.pop(context);
    }
  });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "Incoming Call",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 10),
          Text(
            widget.call.type == "video" ? "Video Call" : "Audio Call",
            style: const TextStyle(color: Colors.white70),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reject
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 30,
                child: IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  onPressed: () async {
                    await CallService().endCallAndCleanup(widget.call.callId);
                    Navigator.pop(context);
                  },
                ),
              ),

              // Accept
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 30,
                child: IconButton(
                  icon: const Icon(Icons.call, color: Colors.white),
                  onPressed: () async {
                    await CallService().updateCallStatus(
                      widget.call.callId,
                      "accepted",
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => widget.call.type == "video"
                            ? VideoCallScreen(call:widget.call)
                            : AudioCallScreen(call: widget.call),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

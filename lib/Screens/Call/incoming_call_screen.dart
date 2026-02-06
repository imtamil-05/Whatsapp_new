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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: CallService().callStream(widget.call.callId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];

          // 🔥 FIX: listen to RINGING not CALLING
          if (status == 'ended' || status == 'rejected') {
            Future.microtask(() => Navigator.pop(context));
          }
      return Column(
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
                      await CallService().rejectCall(widget.call.callId);
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
                      await CallService().acceptCall(widget.call.callId);
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
      );
        },
      ),
    );
  }
}

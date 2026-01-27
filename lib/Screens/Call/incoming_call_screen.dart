import 'package:flutter/material.dart';
import 'package:whatsapp_new/Screens/Call/audio_call_screen.dart';
import 'package:whatsapp_new/Screens/Call/video_call_screen.dart';
import 'package:whatsapp_new/services/Call_services/Call_Services.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';

class IncomingCallScreen extends StatelessWidget {
  final CallModel call;

  const IncomingCallScreen({super.key, required this.call});

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
            call.type == "video" ? "Video Call" : "Audio Call",
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
                    await CallService().endCall(call.callId);
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
                      call.callId,
                      "accepted",
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => call.type == "video"
                            ? VideoCallScreen(call: call)
                            : AudioCallScreen(call: call),
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

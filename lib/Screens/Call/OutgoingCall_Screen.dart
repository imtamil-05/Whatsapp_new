import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp_new/Screens/Call/audio_call_screen.dart';
import 'package:whatsapp_new/Screens/Call/video_call_screen.dart';
import 'package:whatsapp_new/services/Call_services/Call_Services.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';

class OutgoingCallScreen extends StatefulWidget {
  final CallModel call;

  const OutgoingCallScreen({super.key, required this.call});

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  final AudioPlayer _ringPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  Timer? _timeoutTimer;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _startRinging();
    _startTimeout();
  }

  Future<void> _startRinging() async {
    await _ringPlayer.setReleaseMode(ReleaseMode.loop);
    await _ringPlayer.play(AssetSource('sounds/ringing.mp3'));
  }

  Future<void> _stopRinging() async {
    await _ringPlayer.stop();
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 60), () async {
      if (_handled) return;
      _handled = true;

      await _stopRinging();

      await _voicePlayer.play(AssetSource('sounds/not_answered.mp3'));

      await Future.delayed(const Duration(seconds: 3));

      await CallService().endCallAndCleanup(widget.call.callId,"00:00");

      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _ringPlayer.dispose();
    _voicePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<DocumentSnapshot>(
        stream: CallService().callStream(widget.call.callId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'];

          if (status == "accepted" && !_handled) {
            _handled = true;
            _timeoutTimer?.cancel();
            _stopRinging();

            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => widget.call.type == "video"
                      ? VideoCallScreen(call: widget.call)
                      : AudioCallScreen(call: widget.call),
                ),
              );
            });
          }

          /// REJECTED / ENDED → CLOSE SCREEN
          if ((status == "rejected" || status == "ended") && !_handled) {
            _handled = true;
            _timeoutTimer?.cancel();
            _stopRinging();

            Future.microtask(() {
              Navigator.pop(context);
            });
          }

          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  "Calling…",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.call.type == "video" ? "Video Call" : "Audio Call",
                  style: const TextStyle(color: Colors.white70),
                ),

                const Spacer(),

                ///  CANCEL CALL (CALLER SIDE)
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 40),
                  onPressed: () async {
                    await CallService().endCallAndCleanup(widget.call.callId,"00:00");
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}

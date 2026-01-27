import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';
import 'package:whatsapp_new/services/Call_services/Call_Services.dart';
import '../../config/agora_config.dart';

class AudioCallScreen extends StatefulWidget {
  final CallModel call;
  const AudioCallScreen({super.key, required this.call});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  late RtcEngine engine;
  bool muted = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(appId: AgoraConfig.appId),
    );

    await engine.enableAudio();

    await engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.call.channelId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    engine.leaveChannel();
    engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          const Text("Audio Call", style: TextStyle(color: Colors.white)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => muted = !muted);
                  engine.muteLocalAudioStream(muted);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: () async {
                  await CallService().endCall(widget.call.callId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

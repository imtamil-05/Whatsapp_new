import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool speakerOn = true;
  bool remoteJoined = false;
  Timer? _timer;
int _seconds = 0;
String _callDuration = "00:00";
DateTime? _startTime;
void _startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    _seconds++;

    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;

    setState(() {
      _callDuration =
          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    });
  });
}


  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    await engine.enableAudio();

    await engine.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("Audio joined");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            remoteJoined = true;
            _startTimer();
          });
        },
        onUserOffline: (connection, remoteUid, reason) async {
          //await CallService().endCallAndCleanup(widget.call.callId);
          Navigator.pop(context);
        },
      ),
    );

    await engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.call.channelId.isNotEmpty
          ? widget.call.channelId
          : widget.call.callId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    await engine.setEnableSpeakerphone(true);
  }

  void listenCallStatus() {
    FirebaseFirestore.instance
        .collection("calls")
        .doc(widget.call.callId)
        .snapshots()
        .listen((snapshot) {
          if (!snapshot.exists) return;

          final data = snapshot.data()!;
          if (data['startTime'] != null) {
  _startTime = (data['startTime'] as Timestamp).toDate();
  _startDurationTimer();
}
          if (data['status'] == "ended") {
            Navigator.pop(context);
          }
        });
  }

  void _startDurationTimer() {
  if (_startTime == null) return;

  _timer?.cancel();

  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    final diff = DateTime.now().difference(_startTime!);

    int minutes = diff.inMinutes;
    int seconds = diff.inSeconds % 60;

    setState(() {
      _callDuration =
          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    });
  });
}


  @override
  void dispose() {
    _timer?.cancel();
    engine.leaveChannel();
    engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Audio Call"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          Text(
            remoteJoined ? "$_callDuration" : "Connecting...",
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
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
                icon: Icon(
                  speakerOn ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => speakerOn = !speakerOn);
                  engine.setEnableSpeakerphone(speakerOn);
                },
              ),
              IconButton(
                icon: const Icon(Icons.call_end, color: Colors.red),
                onPressed: () async {
                  _timer?.cancel();
                  await CallService().endCallAndCleanup(widget.call.callId, _callDuration);
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

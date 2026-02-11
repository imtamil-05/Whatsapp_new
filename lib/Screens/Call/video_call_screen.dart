import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_new/Models/Call_Models.dart';
import 'package:whatsapp_new/services/Call_services/Call_Services.dart';
import '../../config/agora_config.dart';

class VideoCallScreen extends StatefulWidget {
  final CallModel call;
  const VideoCallScreen({super.key, required this.call});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late RtcEngine engine;
  int? remoteUid;
  bool muted = false;
  bool speakerOn = true;
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
    await [Permission.microphone, Permission.camera].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    await engine.enableVideo();
    await engine.enableAudio();

    await engine.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            remoteUid = remoteUid;
            _startTimer();
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          Navigator.pop(context);
        },
      ),
    );

    await engine.startPreview();

    await engine.joinChannel(
      token: AgoraConfig.token,
      channelId: widget.call.channelId,
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

  Widget localView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget remoteView() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: widget.call.channelId),
        ),
      );
    } else {
      return const Center(
        child: Text(
          "Waiting for user...",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _callDuration,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Positioned.fill(child: remoteView()),
          Positioned(
            top: 40,
            right: 20,
            width: 120,
            height: 160,
            child: Container(child: localView()),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Row(
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
                    icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    onPressed: () {
                      engine.switchCamera();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    onPressed: () async {
                      _timer?.cancel();
                      await CallService().endCallAndCleanup(widget.call.callId,_callDuration);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

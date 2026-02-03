import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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

  @override
  void initState() {
    super.initState();
    initAgora();
    
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(appId: AgoraConfig.appId),
    );

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          setState(() {
            remoteUid = uid;
          });
        },
        onUserOffline: (connection, uid, reason) {
          Navigator.pop(context);
        },
      ),
    );

    await engine.enableVideo();
    await engine.startPreview();

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
        child: Text("Waiting for user...", style: TextStyle(color: Colors.white)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                  icon: const Icon(Icons.call_end, color: Colors.red),
                  onPressed: () async {
                    await CallService().endCallAndCleanup(widget.call.callId);
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () {
                    engine.switchCamera();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

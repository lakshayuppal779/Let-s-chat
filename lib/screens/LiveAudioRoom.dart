import 'package:flutter/material.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';

class LivePage extends StatelessWidget {
  final String roomID;
  final bool isHost;

  const LivePage({Key? key, required this.roomID, this.isHost = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userid=APIs.user.uid;
    String username=APIs.user.displayName ?? '';
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("Leave confirmation",
                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),textAlign: TextAlign.center,),
                content: const Text(
                    "Are you sure you want to leave the Live Audio room?",
                    style: TextStyle(color: Colors.black)),
                actions: [
                  ElevatedButton(
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.blueAccent)),
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("Confirm",style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              );
            },
          ) ?? false;
        },
        child: ZegoUIKitPrebuiltLiveAudioRoom(
          appID: 726006336, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
          appSign: '14e9c7b11d680c2979066db6e658f8c33de61279ff7e4b2a0a5be2a1f00823ae', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
          userID: userid,
          userName: username,
          roomID: roomID,
          config: isHost
              ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
              : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
        ),
      ),
    );
  }
}

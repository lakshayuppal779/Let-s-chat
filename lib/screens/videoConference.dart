import 'package:flutter/material.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatelessWidget {

  final String conferenceID;
  const VideoConferencePage({
    Key? key,
    required this.conferenceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userid=APIs.user.uid;
    String username=APIs.user.displayName ?? '';
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: 636962292, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign: '3c9c8a550bb4527a761294e9834965141eff52caf85c74defff01ace2337fe1c', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: userid,
        userName: username,
        conferenceID: conferenceID,
        // Modify your custom configurations here.
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          turnOnCameraWhenJoining: false,
          turnOnMicrophoneWhenJoining:false,
          useSpeakerWhenJoining: true,
          onLeaveConfirmation: (BuildContext context) async {
            return await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text("Leave the conference",
                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),textAlign: TextAlign.center,),
                  content: const Text(
                      "Are you sure you want to leave the conference?",
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
            );
          },
        ),
      ),

    );
  }
}

// ..layout = ZegoLayout.gallery(
// showScreenSharingFullscreenModeToggleButtonRules:
// ZegoShowFullscreenModeToggleButtonRules.alwaysShow,
// showNewScreenSharingViewInFullscreenMode:
// false) // Set the layout to gallery mode. and configure the [showNewScreenSharingViewInFullscreenMode] and [showScreenSharingFullscreenModeToggleButtonRules].
// ..bottomMenuBarConfig = ZegoBottomMenuBarConfig(buttons: [
// ZegoMenuBarButtonName.chatButton,
// ZegoMenuBarButtonName.switchCameraButton,
// ZegoMenuBarButtonName.toggleMicrophoneButton,
// ZegoMenuBarButtonName.toggleScreenSharingButton
// ])
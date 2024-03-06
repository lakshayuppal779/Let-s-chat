import 'package:flutter/material.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
class VideoCallPage extends StatelessWidget {
  const VideoCallPage({Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  Widget build(BuildContext context) {
    String userid=APIs.user.uid;
    String username=APIs.user.displayName ?? '';
    return ZegoUIKitPrebuiltCall(
      appID: 342646644,
      appSign: '1c03f3310054d35856534499ad5c0f5b842a9715106308f123d4ecbc994c08a4',
      userID: userid,
      userName: username,
      callID: callID,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}

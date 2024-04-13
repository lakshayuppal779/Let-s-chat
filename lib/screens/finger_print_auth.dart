import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/flutter_gemini/chat_screen.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/chatscreen.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintAuth extends StatefulWidget {
  final ChatUser user;
  const FingerprintAuth({Key? key, required this.user}) : super(key: key);

  @override
  _FingerprintAuthState createState() => _FingerprintAuthState();
}

class _FingerprintAuthState extends State<FingerprintAuth> {
  final auth = LocalAuthentication();
  String authorized = " not authorized";
  bool _canCheckBiometric = false;
  late List<BiometricType> _availableBiometric;

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
          localizedReason: 'Scan your finger to authenticate',
          options: const AuthenticationOptions(useErrorDialogs: false)
      );
    } on PlatformException catch (e) {
      log(e.toString());
    }

    if (authenticated) {
      // Navigate to another screen here
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) =>Chatscreen(user: widget.user)),
      );
    }
    setState(() {
      authorized =
      authenticated ? "Authorized success" : "Failed to authenticate";
      log(authorized);
    });
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      log('e');
    }

    if (!mounted) return;
    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future _getAvailableBiometric() async {
    List<BiometricType> availableBiometric = [];

    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      log('e');
    }

    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  @override
  void initState() {
    _checkBiometric();
    _getAvailableBiometric();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Fingerprint Auth")),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Chat lock",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  Icon(Icons.lock,size: 70,color: Colors.blueAccent,),
                  // Image.asset(
                  //   "assets/images/fingerprint.png",
                  //   width: 120.0,
                  // ),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    "Unlock to continue",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _authenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: ContinuousRectangleBorder(),
                        ),
                        child: Text(
                          'Authenticate',
                          style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/screens/Homescreen.dart';

class OTPscreen extends StatefulWidget {
  String verificationid;
  OTPscreen({super.key, required this.verificationid});

  @override
  State<OTPscreen> createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  var otp = TextEditingController();
  void _showAlertdialog(BuildContext context, String text, String text2) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Text(text2),
          backgroundColor: Colors.lightBlue.shade50,
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ok'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('OTP Screen'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 310,
              height: 700,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "OTP verification",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      "Please enter the 6-digit OTP sent to your mobile no",
                      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16,color: Colors.grey),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: TextField(
                        style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),
                        controller: otp,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "######",
                            suffixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't recieve OTP?",
                          style:
                              TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              try {
                                PhoneAuthCredential credential =
                                    await PhoneAuthProvider.credential(
                                        verificationId: widget.verificationid,
                                        smsCode: otp.text.toString());
                                FirebaseAuth.instance
                                    .signInWithCredential(credential)
                                    .then((value) => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeScreen(),
                                        )));
                              }
                              on FirebaseAuthException {
                                Dialogs.showSnackbar(context,"Something Went Wrong! Please try again");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: ContinuousRectangleBorder(),
                            ),
                            child: Text(
                              "Verify OTP",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

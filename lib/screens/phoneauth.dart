import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/screens/otpscreen.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  var phone = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Phone Auth"),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: 310,
              height: 700,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Enter your Mobile Number",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text("We will send an SMS with a verification code on this number",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.grey),),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                      child: TextField(
                        style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            hintText: "10-digit number",
                            suffixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                  verificationCompleted: (PhoneAuthCredential credential){},
                                  verificationFailed: (FirebaseAuthException ex) {},
                                  codeSent: (String verificationid, int? resendtoken) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OTPscreen(verificationid:verificationid),));
                                  },
                                  codeAutoRetrievalTimeout: (String verificationid) {},
                                  phoneNumber: phone.text.toString());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: ContinuousRectangleBorder(),
                            ),
                            child: Text('Send OTP',style: TextStyle(fontSize: 16,color: Colors.white),)),
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

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lets_chat/screens/Homescreen.dart';
import 'package:lets_chat/screens/loginpage.dart';
import 'package:lets_chat/screens/onboarding.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
              ),
              SizedBox(
                height: 170,
                  width: 170,
                  child: Image.asset('assets/images/chat.png',)
              ),
              SizedBox(
                height: 200,
              ),
              // Text('  from',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300,),),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Icon(Icons.electric_bolt_sharp,color: Colors.lightBlue,),
              //     Text('lakshay',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.blue),)
              //   ],
              // )

            ],
          ),
        ),
      ),
    );
  }
}

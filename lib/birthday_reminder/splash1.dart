import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_chat/birthday_reminder/birthday.dart';
import 'package:lets_chat/flutter_gemini/chat_screen.dart';

class BirthdaySplashScreen extends StatefulWidget {
  const BirthdaySplashScreen({super.key});

  @override
  State<BirthdaySplashScreen> createState() => _BirthdaySplashScreenState();
}

class _BirthdaySplashScreenState extends State<BirthdaySplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 1), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BirthdayReminderApp()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 130,
              ),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/undraw_Reminder_re_fe15.png')
              ),
              SizedBox(
                height: 80,
              ),

            ],
          ),
        ),
      ),
    );
  }
}


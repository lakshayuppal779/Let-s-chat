import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lets_chat/screens/loginpage.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        globalBackgroundColor: Colors.white,
        scrollPhysics: BouncingScrollPhysics(),
        pages: [
          PageViewModel(
            titleWidget: const Text("Welcome to Let's Chat!",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            body: "Forge deeper connections and share life's journey through Let's Chat.",
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0), // Adjust top padding as needed
              child: Image.asset("assets/images/undraw_Chatting_re_j55r.png", height: 400, width: 400,),
            ),
          ),
          PageViewModel(
            titleWidget: const Text("Express Yourself",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            body: "Capture life's highlights and share them instantly – from photos and videos to cherished memories.",
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset("assets/images/undraw_Taking_selfie_re_wlgd.png",height: 400,width: 400,),
            ),
          ),
          PageViewModel(
            titleWidget: const Text("       Stay Connected Anytime and Anywhere",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
            body: 'Experience the joy of chatting with loved ones, no matter the distance.',
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset("assets/images/undraw_Connected_re_lmq2.png",height: 400,width: 400,),
            ),
          ),
          PageViewModel(
            titleWidget: const Text("Gemini AI Assistance", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            body: 'Enhance your chatting experience with AI-powered features for better communication.',
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset("assets/images/undraw_Artificial_intelligence_re_enpp.png", height: 400, width: 400),
            ),
          ),
          PageViewModel(
            titleWidget: const Text("Video Conferencing", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            body: 'Connect face-to-face with friends and colleagues through seamless video conferencing.',
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Image.asset("assets/images/undraw_Group_video_re_btu7.png", height: 400, width: 400),
            ),
          ),
        ],
        onDone: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginpage(),));
        },
        onSkip: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginpage(),));
        },
        showSkipButton:true,
        skip: Text("Skip",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.blueAccent),),
        done: Text("Done",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.blueAccent),),
        next: Icon(Icons.arrow_forward,size: 26,color: Colors.blueAccent,),
        dotsDecorator: DotsDecorator(
          size: Size.square(10.0),
          activeSize:Size(20.0,10.0),
          color: Colors.black87,
          activeColor: Colors.blueAccent,
          spacing: EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }
}

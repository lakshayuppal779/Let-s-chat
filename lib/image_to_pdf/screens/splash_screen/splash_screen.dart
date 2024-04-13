import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lets_chat/image_to_pdf/screens/main_screen/main_screen.dart';
import '../../constant/constant.dart';

class SplashScreenImagetopdf extends StatefulWidget {
  const SplashScreenImagetopdf({Key? key}) : super(key: key);

  @override
  State<SplashScreenImagetopdf> createState() => _SplashScreenImagetopdfState();
}

class _SplashScreenImagetopdfState extends State<SplashScreenImagetopdf> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const MainScreen()));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    width =MediaQuery.of(context).size.width;
    return SafeArea(
        child:Scaffold(
          body: Center(
            child: Image.asset("assets/images/logo.png",scale: width *0.008,),
          ),
        ),
    );
  }
}

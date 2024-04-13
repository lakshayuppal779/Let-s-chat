import 'package:flutter/material.dart';
import 'package:lets_chat/screens/contactform.dart';

class SupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Let\'s Chat',
                style: TextStyle(fontSize: 31),
              ),
              Text(
                'Support Centre',
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(height: 30),
              Text(
                "We're here to help! Have a question or feedback? Reach out to us:",
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(
                  height: 300,
                  width: 300,
                  child: Image.asset('assets/images/undraw_Active_support_re_b7sj.png')
              ),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) => ContactFormScreen(),));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: ContinuousRectangleBorder(),
                    ),
                    child: Text(
                      'Contact us',
                      style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.normal),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

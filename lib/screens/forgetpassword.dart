import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class forgetpassword extends StatefulWidget {
  const forgetpassword({super.key});

  @override
  State<forgetpassword> createState() => _forgetpasswordState();
}

class _forgetpasswordState extends State<forgetpassword> {
  var utext=TextEditingController();
  forgotpassword(String email){
    if(email==""){
      _showAlertdialog(context, "ALERT!", "Enter a email to reset password");
    }
    else{
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    }
  }
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
            ElevatedButton(onPressed: () {
              Navigator.of(context).pop();
            }, child: Text('ok'))
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
          title: Text('Reset Password'),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
                width: 310,
                height: 745,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 250,
                            width: 250,
                            child: Image.asset('assets/images/undraw_Forgot_password_re_hxwm.png')
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Enter your Email",
                            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        Text("We will send a link to this email to reset the password.",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal,color: Colors.grey),),
                        SizedBox(
                          height: 25,
                        ),
                        TextField(
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),
                          controller: utext,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              label: Text('Email'),
                              suffixIcon: Icon(Icons.mail),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        SizedBox(
                          width: 310,
                          height: 50,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ElevatedButton(onPressed: (){
                              forgotpassword(utext.text.toString());
                            },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: ContinuousRectangleBorder(),
                                ),
                                child: Text(
                                  "Reset Password",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                )
                            ),
                          ),
                        )
                      ]
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}

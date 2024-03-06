import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/screens/Homescreen.dart';
import 'package:lets_chat/screens/forgetpassword.dart';
import 'package:lets_chat/screens/signup.dart';


class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  var utext = TextEditingController();
  var ptext = TextEditingController();
  bool passwordVisible=false;
  login(String email, String password) async {
    if (email == "" && password == "") {
      _showAlertdialog(context, "ALERT!", "Enter all the required fields.");
    } else {
      UserCredential? usercredential;
      try {
            usercredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            )));
      }
      on FirebaseAuthException catch (ex) {
        _showAlertdialog(context, "ALERT!", "Something Went Wrong!");
      }
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
  SigninWithgoogle()async{
    try {
      await InternetAddress.lookup("google.com");
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser!.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      print(userCredential.user?.displayName);

      if(userCredential.user!=null){
        if((await APIs.Userexits())){
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>HomeScreen(),));
        }
        else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>HomeScreen(),));
          });
        }
      }
    }
    catch(ex) {
      Navigator.pop(context);
      Dialogs.showSnackbar(context,"Login failed! Please try again");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordVisible=true;
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Welcome to Let's Chat"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 300,
              height: 700,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 125,
                        height:125,
                        child: Image.asset('assets/images/chat.png')
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextField(
                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17),
                      controller: utext,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          label: Text('Username'),
                          suffixIcon: Icon(Icons.mail),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17),
                      controller: ptext,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                          label: Text('Password'),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(
                                    () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            login(utext.text.toString(), ptext.text.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: ContinuousRectangleBorder(),
                          ),
                          child: Text(
                            'Log In',
                            style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(child: Text('or',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.grey),)),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ElevatedButton.icon(
                            onPressed: (){
                              Dialogs.showProgressbar(context);
                              SigninWithgoogle();
                              setState(() {
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape:RoundedRectangleBorder(),
                              elevation: 2,
                            ),
                            icon:Image.asset('assets/images/google.png',height: 30,),
                            label: Text(" Continue with Google",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?"),
                        SizedBox(
                          width: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => signup(),
                                ));
                          },
                          child: Text('Sign up'),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => forgetpassword(),
                            ));
                      },
                      child: Text('Forget Password?'),
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

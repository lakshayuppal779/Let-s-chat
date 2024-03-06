import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lets_chat/screens/Homescreen.dart';
import 'package:lets_chat/screens/loginpage.dart';
import 'package:lets_chat/screens/phoneauth.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  var ustext = TextEditingController();
  var pstext = TextEditingController();
  bool passwordVisible=false;
  bool _ischecked=false;
  bool _ischeckedi=false;
  File? pickedImage;

  signup(String email, String password) async {
    if (email == "" && password == "" && pickedImage == "") {
      _showAlertdialog(context, "ALERT!", "Enter the required fields.");
    } else {
      UserCredential? usercredential;
      try {
        usercredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),)));
      } on FirebaseAuthException catch (ex) {
        _showAlertdialog(context, "ALERT!", ex.code.toString());
      }
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
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sign up'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 300,
              height: 900,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Let's Chat",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        "Where every message",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "sparks a connection",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextField(
                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),
                      controller: ustext,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          label: Text('Email'),
                          suffixIcon: Icon(Icons.mail),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 14),
                      controller: pstext,
                      keyboardType: TextInputType.text,
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
                      height: 15,
                    ),
                    // Row(
                    //   children: [
                    //     Checkbox(value: _ischecked, onChanged: (value){
                    //       setState(() {
                    //         _ischecked=value!;
                    //       });
                    //     }),
                    //     Flexible(
                    //       child: Text(
                    //         "I agree to the Let's Chat Terms of service.",
                    //         style: TextStyle(color: Colors.black,fontSize: 12),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "By clicking Sign up , I agree to the Let's Chat Terms of service and accept that it can use my data for the service and everything else described in the Privacy policy and Data processing agreement.",
                            style: TextStyle(color: Colors.black,fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            signup(ustext.text.toString(), pstext.text.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: ContinuousRectangleBorder(),
                          ),
                          child: Text(
                            'Sign up',
                            style: TextStyle(color: Colors.white,fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(child: Text('or',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w400,color: Colors.grey),)),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ElevatedButton.icon(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneAuth(),));
                        },
                          icon:Icon(Icons.phone,color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: ContinuousRectangleBorder(),
                          ),
                          label: Text("Sign up with phone no",style: TextStyle(color: Colors.white,fontSize: 16),),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        SizedBox(
                          width: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => loginpage(),
                                ));
                          },
                          child: Text('Sign in'),
                        ),
                      ],
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

  // void showAlertdialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Pick image from"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               onTap: () {
  //                 pickimage(ImageSource.camera);
  //                 Navigator.pop(context);
  //               },
  //               leading: Icon(Icons.camera),
  //               title: Text('Camera'),
  //             ),
  //             ListTile(
  //               onTap: () {
  //                 pickimage(ImageSource.gallery);
  //                 Navigator.pop(context);
  //               },
  //               leading: Icon(Icons.image),
  //               title: Text('Gallery'),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: Colors.lightBlue.shade50,
  //         shape: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(11),
  //         ),
  //       );
  //     },
  //   );
  // }
  //
  // pickimage(ImageSource imageSource) async {
  //   try {
  //     final photo = await ImagePicker().pickImage(source: imageSource);
  //     if (photo == null) return;
  //     final Tempimage = File(photo.path);
  //     setState(() {
  //       pickedImage = Tempimage;
  //     });
  //   } catch (ex) {
  //     _showAlertdialog(context, "Alert", ex.toString());
  //   }
  // }

  // uploaddata() async {
  //   UploadTask uploadTask = FirebaseStorage.instance
  //       .ref("Profile pics")
  //       .child(ustext.text.toString())
  //       .putFile(pickedImage!);
  //   TaskSnapshot taskSnapshot = await uploadTask;
  //   String Url = await taskSnapshot.ref.getDownloadURL();
  //   FirebaseFirestore.instance
  //       .collection("Pics")
  //       .doc(ustext.text.toString())
  //       .set({
  //     "Email": ustext.text.toString(),
  //     "image": Url,
  //   })
  //       .then((value) => _showAlertdialog(context, "Good job", "User uploaded"))
  //       .then((value) => Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => HomeScreen(),
  //       )));
  // }
}

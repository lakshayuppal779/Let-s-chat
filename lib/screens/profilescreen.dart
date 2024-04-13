import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/loginpage.dart';

class Profilescreen extends StatefulWidget {
  final ChatUser user;
  const Profilescreen({super.key, required this.user});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final _formkey= GlobalKey<FormState>();
  File? pickedImage;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("My Profile"),
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FloatingActionButton.extended(
              onPressed: () async {
                Dialogs.showProgressbar(context);
                await APIs.updateActiveStatus(false);
                await FirebaseAuth.instance.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value){
                    //for removing progressbar
                    Navigator.pop(context);

                    //for removing profile screen and returning to home screen
                    Navigator.pop(context);

                    //replacing home screen with login screen
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const loginpage(),));
                  });
                });
              },

              icon: Icon(Icons.logout,color: Colors.white,size: 28,),
              label: Text("Logout",style: TextStyle(color: Colors.white,fontSize: 16),),
              backgroundColor: Colors.redAccent,
            ),
          ),
        ),
        body: Form(
          key: _formkey,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 310,
                height: 700,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: pickedImage!=null?CircleAvatar(
                              radius: 80,
                              backgroundImage: FileImage(pickedImage!),

                            ):CachedNetworkImage(
                              width: 160,
                              height: 160,
                              imageUrl: widget.user.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(),
                              errorWidget: (context, url, error) => CircleAvatar(child: const Icon(Icons.account_circle)),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -16,
                            child: MaterialButton(
                              onPressed: (){
                              _showbottomsheet();
                               },
                              height: 40,
                              child: Icon(Icons.camera_alt_rounded,color: Colors.blue),
                              shape: CircleBorder(),
                              color: Colors.white,
                              elevation: 1,

                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(widget.user.email,style: TextStyle(fontSize: 16,color: Colors.blue,fontWeight: FontWeight.normal),),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 320,
                        child: TextFormField(
                          onSaved: (val)=>APIs.me.name=val ?? '',
                          validator: (val)=>val!=null && val.isNotEmpty ? null:"Required field",
                          initialValue: widget.user.name,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              label: Text('Name'),
                              prefixIcon: Icon(Icons.person),
                              suffixIcon: Icon(Icons.edit),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 320,
                        child: TextFormField(
                          onSaved: (val)=>APIs.me.about=val ?? '',
                          validator: (val)=>val!=null && val.isNotEmpty ? null:"Required field",
                          initialValue: widget.user.about,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              label: Text('About'),
                              prefixIcon: Icon(Icons.info_outline),
                              suffixIcon: Icon(Icons.edit),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),

                      SizedBox(
                        width: 180,
                        height: 45,
                        child: ElevatedButton.icon(onPressed: (){
                          if(_formkey.currentState!.validate()){
                            _formkey.currentState!.save();
                            APIs.updateuserinfo();
                            uploaddata().then((value) => Dialogs.showSnackbar(context, "Profile Updated Successfully"));
                          }
                        },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                            icon: Icon(Icons.edit,color: Colors.white,size: 26,),
                            label: Text("Edit profile",style: TextStyle(color: Colors.white,fontSize: 16),),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showbottomsheet(){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_){
     return ListView(
       shrinkWrap: true,
       padding: const EdgeInsets.only(top: 5,bottom: 40),
       children: [
         Text("Profile Photo",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),textAlign:TextAlign.center,),
         SizedBox(
           height: 20,
         ),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             ElevatedButton(onPressed: (){
               pickimage(ImageSource.camera);
               Navigator.pop(context);
             },
                 style: ElevatedButton.styleFrom(
                   shape: CircleBorder(),
                   fixedSize: Size(130, 130),
                 ),
                 child: Image.asset("assets/images/camera.png")),
             ElevatedButton(onPressed: (){
               pickimage(ImageSource.gallery);
               Navigator.pop(context);
             },
                 style: ElevatedButton.styleFrom(
                   shape: CircleBorder(),
                   fixedSize: Size(130, 130),
                 ),
                 child: Image.asset("assets/images/picture.png")),
           ],
         )
       ],
     );
    });
  }
  pickimage(ImageSource imageSource) async {
    try {
      final photo = await ImagePicker().pickImage(source: imageSource);
      if (photo == null) return;
      final Tempimage = File(photo.path);
      setState(() {
        pickedImage = Tempimage;
      });
    }
    catch (ex) {
      Dialogs.showSnackbar(context, "Something went wrong! Please try again");
    }
  }

  uploaddata() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("Profile pics")
        .child(APIs.user.uid)
        .putFile(pickedImage!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String Url = await taskSnapshot.ref.getDownloadURL();
    APIs.me.image=Url;
    APIs.updateuserinfo();
  }

}

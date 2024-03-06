import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/flutter_gemini/splash.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/LiveAudioRoom.dart';
import 'package:lets_chat/screens/payment.dart';
import 'package:lets_chat/screens/profilescreen.dart';
import 'package:lets_chat/screens/videoConference.dart';
import 'package:lets_chat/widgets/chat_user_card.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> list=[];

  //for storing search items
  final List<ChatUser> _searchlist=[];

  //for storing search status
  bool _isSearching  = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getselfinfo();
    SystemChannels.lifecycle.setMessageHandler((message){
      if(FirebaseAuth.instance.currentUser!=null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
        return Future.value(message);
      });
  }
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
           setState(() {
             _isSearching=!_isSearching;
           });
           return Future.value(false);
          }
          else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching?TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter Name,Email...",
              ),
              autofocus: true,
              style: TextStyle(fontSize: 17,letterSpacing: 0.5),
              onChanged: (val){
                //search logic
                _searchlist.clear();
                for(var i in list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchlist.add(i);
                  }
                  setState(() {
                    _searchlist;
                  });
                }
              },
            ):Text("Let's Chat"),
            leading: Icon(Icons.home,size: 26,),
            actions: [
              IconButton(onPressed: () {
                setState(() {
                  _isSearching=!_isSearching;

                });
              }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search,size: 26,)),
              IconButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profilescreen(user: APIs.me),));
              }, icon: Icon(Icons.more_vert,size: 26,)),
            ],
            backgroundColor: Colors.blueAccent,
          ),
          bottomNavigationBar: SizedBox(
            height: 88,
            child: CurvedNavigationBar(
              backgroundColor: Colors.blueAccent,
              animationDuration: Duration(milliseconds: 300),
              items: <Widget>[
                Icon(Icons.home, size: 27),
                FaIcon(FontAwesomeIcons.robot,size: 23,),
                SizedBox(
                    height: 27,
                    width: 27,
                    child: Image.asset('assets/images/get-money.png',color: Colors.black,)
                ),
                SizedBox(
                    height: 27,
                    width: 27,
                    child: Image.asset('assets/images/headphone.png',color: Colors.black,)
                ),
                SizedBox(
                  height: 27,
                    width: 27,
                    child: Image.asset('assets/images/video-conference.png',color: Colors.black,)
                ),
              ],
              onTap: (index) async {
                if(index==0){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                }
                if(index==1){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen(),));
                }
                if(index==2){
                  // final XFile? photo = await ImagePicker()
                  //     .pickImage(source: ImageSource.camera);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RazorpayPage(),));
                }
                if(index==3){
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => Contacts(),));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LivePage(roomID: "4")));
                }
                if(index==4){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoConferencePage(conferenceID: "3"),));
                }
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen(),));
              _addChatUserDialog();
            },
            shape: StadiumBorder(),
            child: Icon(Icons.person_add_alt_rounded,size: 30,color: Colors.white,),
            backgroundColor: Colors.blueAccent,
          ),
          body:StreamBuilder(
            stream: APIs.getMyUsersId(),

            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
              //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

              //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          list = data
                              ?.map((e) => ChatUser.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchlist.length
                                    : list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatuserCard(
                                      user: _isSearching
                                          ? _searchlist[index]
                                          : list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Connections Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }
  void _addChatUserDialog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: Row(
            children: const [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              Text('  Add User',style: TextStyle(fontSize: 23),)
            ],
          ),

          //content
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email = value,
            decoration: InputDecoration(
              hintText: "Email Id",
                prefixIcon: Icon(Icons.email,color: Colors.blue,),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                )),

            //update button
            MaterialButton(
                onPressed: () async {
                  //hide alert dialog
                  Navigator.pop(context);
                  if (email.isNotEmpty) {
                    await APIs.addChatUser(email).then((value) {
                      if (!value) {
                        Dialogs.showSnackbar(
                            context, 'User does not Exists!');
                      }
                    });
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }
}

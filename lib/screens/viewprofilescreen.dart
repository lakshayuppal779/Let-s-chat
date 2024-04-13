import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/call.dart';
import 'package:lets_chat/screens/profilepic.dart';
import 'package:lets_chat/screens/videocall.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfilescreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfilescreen({super.key, required this.user});

  @override
  State<ViewProfilescreen> createState() => _ViewProfilescreenState();
}

class _ViewProfilescreenState extends State<ViewProfilescreen> {
  bool isChatLocked = false;
  bool isvanishmode = false;
  bool ismute = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ismute = prefs.getBool('mute_notification') ?? false;
      isChatLocked = prefs.getBool('chat_lock') ?? false;
      isvanishmode = prefs.getBool('vanish_mode') ?? false;
      // Load other settings similarly
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (String value) {
                if (value == 'Reminder') {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) =>BirthdaySplashScreen()));
                } else if (value == 'My_profile') {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) =>Profilescreen(user: APIs.me),));
                } else if (value == 'support') {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) =>SupportScreen()));
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'My_profile',
                    child: Text('Clear Chat'),
                  ),
                  PopupMenuItem(
                    value: 'Reminder',
                    child: Text('Reminder'),
                  ),
                  PopupMenuItem(
                    value: 'Make_groups',
                    child: Text('Share'),
                  ),
                  PopupMenuItem(
                    value: 'support',
                    child: Text('Schedule message'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(
                              milliseconds:
                                  500), // Set your desired duration here
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation) {
                            return Profilepic(user: widget.user);
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'profilepic',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: CachedNetworkImage(
                          width: 160,
                          height: 160,
                          imageUrl: widget.user.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => CircleAvatar(
                              child: const Icon(Icons.account_circle)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.user.name,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.black54,
                        fontWeight: FontWeight.normal),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(callID: '1'),));

                        },
                          child: GridItem(icon: Icons.call, name: 'Audio')
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCallPage(callID: "2")));

                        },
                          child: GridItem(icon: Icons.videocam, name: 'Video')
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                          child: GridItem(icon: Icons.message, name: 'Message')
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            widget.user.about,
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Colors.blueAccent,
                      ),
                      title: Text('Mute notifications'),
                      trailing: Switch(
                        value: ismute,
                        onChanged: (value) async {
                          setState(() {
                            ismute = value;
                          });
                          // Save the mute notification state in shared preferences
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool('mute_notification', value);
                          APIs.toggleMuteNotification(APIs.me, widget.user, value);
                        },
                        activeTrackColor: Colors.blueAccent,
                        activeColor: Colors.white,
                      ),

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.lock,
                        color: Colors.blueAccent,
                      ),
                      title: Text('Chat lock'),
                      subtitle: Text('Lock and hide this chat on this device.'),
                      trailing: Switch(
                        value: isChatLocked,
                        onChanged: (value) async {
                          setState(() {
                            isChatLocked = value;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool('chat_lock', value);
                          APIs.toggleChatLock(APIs.me, widget.user, value);
                        },
                        activeTrackColor: Colors
                            .blueAccent, // Change the color of the active track
                        activeColor: Colors
                            .white, // Change the color of the thumb when active
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.enhanced_encryption,
                        color: Colors.blueAccent,
                      ),
                      title: Text('Encryption'),
                      subtitle:
                          Text('Messages and calls are end-to-end encrypted.'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.image_outlined,
                        color: Colors.blueAccent,
                      ),
                      title: Text('Theme'),
                      subtitle: Text('Tap to change the chat theme.'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.blueAccent,
                      ),
                      title: Text('Vanish Mode'),
                      subtitle: Text(
                          'Seen messages will disappear when you close the chat.'),
                      trailing: Switch(
                        value: isvanishmode,
                        onChanged: (value) async {
                          setState(() {
                            isvanishmode = value;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setBool('vanish_mode', value);
                          APIs.toggleVanishMode(APIs.me, widget.user, value);
                        },
                        activeTrackColor: Colors
                            .blueAccent, // Change the color of the active track
                        activeColor: Colors
                            .white, // Change the color of the thumb when active
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: (){
                        _showBlockConfirmationDialog(context);
                      },
                      child: ListTile(
                        leading: Text(
                          '🚫',
                          style: TextStyle(fontSize: 21),
                        ),
                        title: Text(
                          'Block ' + widget.user.name,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: (){
                        _showReportConfirmationDialog(context);
                      },
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/report.png',
                          color: Colors.redAccent,
                          height: 28,
                          width: 28,
                        ),
                        title: Text(
                          'Report ' + widget.user.name,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Joined On: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        MyDateutil.getLastMessageTime(
                            context: context,
                            time: widget.user.createdAt,
                            showYear: true),
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Block ${widget.user.name}?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Blocked contacts cannot call or send you messages.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to block ${widget.user.name}?",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                // Block the chat user
                // You need to implement block functionality here
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Block",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  void _showReportConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report ${widget.user.name}?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "If you block and report this contact, all the messages in this chat will be deleted. This contact will not be notified",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "Are you sure you want to report and block ${widget.user.name}?",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () {
                // Report and block the chat user
                // You need to implement report and block functionality here
                Navigator.of(context).pop(); // Close the dialog
               APIs.clearAllmessages(widget.user);
              },
              child: Text(
                "Report",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

}

class GridItem extends StatelessWidget {
  final IconData icon;
  final String name;

  const GridItem({Key? key, required this.icon, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      width: 75,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(width: 0.5, color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: Colors.blueAccent,
          ),
          SizedBox(height: 5),
          Text(
            name,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

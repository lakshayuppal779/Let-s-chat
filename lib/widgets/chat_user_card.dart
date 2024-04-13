import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:lets_chat/screens/chatscreen.dart';
import 'package:lets_chat/screens/finger_print_auth.dart';
import 'package:lets_chat/widgets/dialogs/profile_dialog.dart';

class ChatuserCard extends StatefulWidget {
  final ChatUser user;
  const ChatuserCard({super.key, required this.user});

  @override
  State<ChatuserCard> createState() => _ChatuserCardState();
}

class _ChatuserCardState extends State<ChatuserCard> {
  Message? _message;
  bool _isLongPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isLongPressed) {
          setState(() {
            _isLongPressed = false;
          });
        }
      },
      child: WillPopScope(
        onWillPop: (){
          if(_isLongPressed){
            setState(() {
              _isLongPressed=!_isLongPressed;
            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }
        },
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          elevation: _isLongPressed ? 8.0 : 0.5,
          child: InkWell(
            onTap: () async {
              if (await APIs.isChatLocked(APIs.me, widget.user)) {
                // Navigate to another screen if chat is locked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FingerprintAuth(user: widget.user),
                  ),
                );
              }
              else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Chatscreen(user: widget.user),
                  ),
                );
              }
            },
            onLongPress: () {
              setState(() {
                _isLongPressed = !_isLongPressed;
              });
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data =snapshot.data?.docs;
                final list=data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if(list.isNotEmpty) _message=list[0];
                return ListTile(
                  leading: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(context: context, builder: (_) => ProfileDialog(user: widget.user,));
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CachedNetworkImage(
                            width: 50,
                            height: 50,
                            imageUrl: widget.user.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => CircleAvatar(child: const Icon(Icons.account_circle)),
                          ),
                        ),
                      ),
                      if (_isLongPressed)
                        Positioned(
                          bottom: -13,
                          right: -34,
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: MaterialButton(
                              onPressed: () {},
                              child: Icon(Icons.check, color: Colors.white,size: 16,),
                              shape: CircleBorder(),
                              color: Colors.blueAccent,
                              elevation: 1,
                              height: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(widget.user.name,style: TextStyle(overflow: TextOverflow.ellipsis),),
                  subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                          : widget.user.about, style: const TextStyle(overflow: TextOverflow.ellipsis),
                      maxLines: 1),
                  trailing: _isLongPressed // Show different trailing icons based on selection
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.volume_off,color: Colors.blueAccent,),
                        onPressed: () {}, // Add your mute functionality here
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,color: Colors.blueAccent,),
                        onPressed: () => _showDeleteConfirmationDialog(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.block,color: Colors.blueAccent,),
                        onPressed: () => _showBlockConfirmationDialog(context),
                      ),
                    ],
                  )
                      : _message == null
                      ? Icon(Icons.chat_outlined, color: Colors.grey, size: 24)
                      : _message!.read.isEmpty && _message!.fromID != APIs.user.uid
                      ? Icon(Icons.mark_unread_chat_alt_outlined, color: Colors.grey, size: 24)
                      : Text(
                    MyDateutil.getLastMessageTime(context: context, time: _message!.sent),
                    style: const TextStyle(color: Colors.black54),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete this chat"),
          content: Text("Are you sure you want to delete this chat user?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel",style: TextStyle(fontSize: 16, color: Colors.blueAccent),),
            ),
            TextButton(
              onPressed: () {
                // Delete the chat user from Firebase
                APIs.deleteChatUser(widget.user);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete",style: TextStyle(fontSize: 16, color: Colors.red),),
            ),
          ],
        );
      },
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
}

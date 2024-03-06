import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:lets_chat/screens/chatscreen.dart';
import 'package:lets_chat/widgets/dialogs/profile_dialog.dart';

class ChatuserCard extends StatefulWidget {
  final ChatUser user;
  const ChatuserCard({super.key, required this.user});

  @override
  State<ChatuserCard> createState() => _ChatuserCardState();
}

class _ChatuserCardState extends State<ChatuserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
      ),
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => Chatscreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data =snapshot.data?.docs;
            log('last message: $data');
            final list=data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty) _message=list[0];
            return ListTile(
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_) =>ProfileDialog(user: widget.user,) );
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
              title: Text(widget.user.name),
              subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                      ? 'image'
                      : _message!.msg
                      : widget.user.about,
                  maxLines: 1),
              trailing: _message == null
                  ? Icon(Icons.chat_outlined,color: Colors.grey,size: 24,)//show nothing when no message is sent
                  : _message!.read.isEmpty &&
                  _message!.fromID != APIs.user.uid
                  ?
              //show for unread message
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    borderRadius: BorderRadius.circular(10)),
              )
                  :
              //message sent time
              Text(
                MyDateutil.getLastMessageTime(
                    context: context, time: _message!.sent),
                style: const TextStyle(color: Colors.black54),
              ),
            );
          },
        ),
      ),
    );
  }
}

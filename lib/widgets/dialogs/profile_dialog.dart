import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/screens/viewprofilescreen.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: 280,
        width: 280,
        child: Stack(
          children: [
            Align(
              alignment:Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: CachedNetworkImage(
                  width: 180,
                  height: 180,
                  imageUrl:user.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      CircularProgressIndicator(),
                  errorWidget: (context, url, error) => CircleAvatar(
                      child: const Icon(Icons.account_circle)),
                ),
              ),
            ),
            Positioned(
              top: 12,
                left: 15,
                child: Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),)),
            Positioned(
              top: 2,
              right: 4,
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                     Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilescreen(user: user),));
                  },
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(0),
                  minWidth: 0,
                  child: Icon(Icons.info_outline,color: Colors.blue,size: 30,)),
            ),
          ],
        ),
      ),
    );
  }
}

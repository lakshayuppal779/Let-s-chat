import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_user.dart';

class StatusUserCard extends StatefulWidget {
  final ChatUser user;
  const StatusUserCard({super.key, required this.user});

  @override
  State<StatusUserCard> createState() => _StatusUserCardState();
}

class _StatusUserCardState extends State<StatusUserCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        elevation: 0.5,
        child: InkWell(
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (_) => Chatscreen(
            //           user: widget.user,
            //         )));
          },
          child: ListTile(
            leading: InkWell(
              onTap: (){
                // showDialog(context: context, builder: (_) =>ProfileDialog(user: widget.user,) );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.blueAccent, // Add your desired border color here
                    width: 2.5,
                    // Adjust the border width as needed
                  ),
                ),
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
            ),
            title: Text(widget.user.name),
          ),
        ),
      ),
    );
  }
}
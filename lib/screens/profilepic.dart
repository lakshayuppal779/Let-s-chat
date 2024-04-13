import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/models/chat_user.dart';

class Profilepic extends StatefulWidget {
  final ChatUser user;
  const Profilepic({super.key, required this.user});

  @override
  State<Profilepic> createState() => _ProfilepicState();
}

class _ProfilepicState extends State<Profilepic> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            height: 400,
            width: 400,
            child: Hero(
              tag: 'profilepic',
              child: CachedNetworkImage(
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
      ),
    );
  }
}

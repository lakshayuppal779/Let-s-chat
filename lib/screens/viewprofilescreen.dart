import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/models/chat_user.dart';

class ViewProfilescreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfilescreen({super.key, required this.user});

  @override
  State<ViewProfilescreen> createState() => _ViewProfilescreenState();
}

class _ViewProfilescreenState extends State<ViewProfilescreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        body: Center(
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
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(widget.user.email, style: TextStyle(fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.normal),),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('About:',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w500),),
                        Text(widget.user.about, style: TextStyle(fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal),),
                      ],
                    ),
                    SizedBox(
                      height: 330,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Joined On:',style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w500),),
                        Text(MyDateutil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true), style: TextStyle(fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.normal),),
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
}
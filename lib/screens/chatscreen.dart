import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:lets_chat/screens/call.dart';
import 'package:lets_chat/screens/videocall.dart';
import 'package:lets_chat/screens/viewprofilescreen.dart';
import 'package:lets_chat/widgets/message_user_card.dart';

class Chatscreen extends StatefulWidget {
  final ChatUser user;

  const Chatscreen({super.key, required this.user});

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  //for storing all messages
  List<Message> list = [];
  final _textcontroller = TextEditingController();
  bool showemoji = false;
  bool _isuploading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // Dispose the scroll controller
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: () {
            if (showemoji) {
              setState(() {
                showemoji = !showemoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                flexibleSpace: _appbar(),
                backgroundColor: Colors.blueAccent,
              ),
              backgroundColor: Colors.lightBlue.shade50,
              body: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: APIs.getAllmessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;
                            list = data
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            if (list.isNotEmpty) {
                              WidgetsBinding.instance?.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              });
                              return ListView.builder(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: 2),
                                itemBuilder: (context, index) {
                                  return Messagecard(
                                    message: list[index],
                                  );
                                },
                                itemCount: list.length,
                              );
                            } else {
                              return Center(
                                  child: Text(
                                'Say Hii! 👋',
                                style:
                                    TextStyle(fontSize: 25, color: Colors.blue),
                              ));
                            }
                        }
                      },
                    ),
                  ),
                  if (_isuploading)
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )),
                  _chatInput(),
                  if (showemoji)
                    EmojiPicker(
                        textEditingController: _textcontroller,
                        config: Config(
                          height: 256,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 8,
                            backgroundColor: Colors.lightBlue.shade50,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.20 : 1.0),
                          ),
                        )),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  Widget _appbar() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilescreen(user: widget.user),));
      },
      child: StreamBuilder(
        stream: APIs.getUserinfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  width: 40,
                  height: 40,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      CircleAvatar(child: const Icon(Icons.account_circle)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfilescreen(user: widget.user),));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(list.isNotEmpty ? list[0].name : widget.user.name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white,overflow: TextOverflow.ellipsis)),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              list.isNotEmpty
                                  ? list[0].isOnline ? 'online' : MyDateutil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                                  : MyDateutil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                              style: TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCallPage(callID: "1"),));
                  },
                  icon: Icon(
                    Icons.video_call_rounded,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CallPage(callID: "2"),));
                  },
                  icon: Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 20,
                  )),
              IconButton(
                  onPressed: () {
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          showemoji = !showemoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.blue,
                        size: 26,
                      )),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        setState(() {
                          if (showemoji) showemoji = !showemoji;
                        });
                      },
                      controller: _textcontroller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: TextStyle(color: Colors.blue),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final List<XFile> photos =
                            await ImagePicker().pickMultiImage();
                        if (photos.isNotEmpty) {
                          for (var i in photos) {
                            setState(() {
                              _isuploading = true;
                            });
                            await uploaddata(widget.user, File(i.path));
                            setState(() {
                              _isuploading = false;
                            });
                          }
                        }
                      },
                      icon: Icon(
                        Icons.photo,
                        color: Colors.blue,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final XFile? photo = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          setState(() {
                            _isuploading = true;
                          });
                          await uploaddata(widget.user, File(photo.path));
                          setState(() {
                            _isuploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blue,
                        size: 26,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            elevation: 3,
            onPressed: () {
              if (_textcontroller.text.isNotEmpty) {
                if (list.isEmpty) {
                  //on first message (add user to my_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textcontroller.text, Type.Text);
                } else {
                  //simply send message
                  APIs.sendMessage(
                      widget.user, _textcontroller.text, Type.Text);
                }
                _textcontroller.text = '';
              }
            },
            minWidth: 0,
            shape: CircleBorder(),
            color: Colors.blueAccent,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            child: Icon(Icons.send, size: 30, color: Colors.white),
          )
        ],
      ),
    );
  }

  uploaddata(ChatUser chatUser, File file) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref()
        .child(
            'images/${APIs.getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}')
        .putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }
}

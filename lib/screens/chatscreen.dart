import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/image_to_pdf/screens/splash_screen/splash_screen.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:lets_chat/screens/Translator.dart';
import 'package:lets_chat/screens/call.dart';
import 'package:lets_chat/screens/scheduledMessage.dart';
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
  bool isVanishMode = false;

  @override
  Future<void> dispose() async {
    // Dispose the scroll controller
    _scrollController.dispose();
    super.dispose();
    // Check if isvanishmode is true
    if (isVanishMode) {
    // Call deleteSeenMessages function
      deleteVanishModeMessages();
    }
  }

  @override
  void initState() {
    super.initState();
    checkVanishMode(); // Added
  }


  void checkVanishMode() async {
    bool vanishMode = await APIs.isVanishMode(APIs.me, widget.user);
    setState(() {
      isVanishMode = vanishMode;
    });
  }

  void deleteVanishModeMessages() async {
    final List<Message> vanishModeMessages = list.where((message) => message.isVanishMode && message.read.isNotEmpty).toList();

    for (var message in vanishModeMessages) {
      await APIs.deleteVanishMessage(message);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isVanishMode
          ? SystemUiOverlayStyle(statusBarColor: Colors.black)
          : SystemUiOverlayStyle(statusBarColor: Colors.blueAccent),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          onWillPop: () async {
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
                backgroundColor: isVanishMode ? Colors.black : Colors.blueAccent,
              ),
              backgroundColor:isVanishMode ? Colors.black : Colors.lightBlue.shade50,
              body: Stack(
                children: [
                  // if (!isVanishMode)
                  // Container(
                  //   decoration: BoxDecoration(
                  //     image: DecorationImage(
                  //       image: AssetImage('assets/images/abstract-lights-grey-background.jpg'),
                  //       fit: BoxFit.cover,
                  //     ),

                  //   ),
                  // ),
                  Column(
                    children: [
                      if (isVanishMode) // Display only if isVanishMode is true
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Vanish mode',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Expanded(
                                    child: Text(
                                      'Seen messages will disappear',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Expanded(
                                    child: Text(
                                      'when you close the chat.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: StreamBuilder(
                          stream: APIs.getAllmessages(widget.user),
                          builder: (context, snapshot) {
                            // Check if the widget is still mounted before accessing the context
                            if (!mounted) {
                              return SizedBox(); // Or any other appropriate widget
                            }
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
                                        message: list[index], user: widget.user,
                                      );
                                    },
                                    itemCount: list.length,
                                  );
                                } else {
                                  return Center(
                                      child: TextButton(
                                        child: Text('Say Hii!👋',
                                          style: TextStyle(fontSize: 25, color: Colors.blue),
                                        ),
                                        onPressed: (){
                                          APIs.sendMessage(widget.user,"Hii!👋", Type.text);
                                        },

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
                              fontSize: 16, fontWeight: FontWeight.w500,color: Colors.white,overflow: TextOverflow.ellipsis)
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Text(
                              list.isNotEmpty
                                  ? list[0].isOnline ? 'online' : MyDateutil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                                  : MyDateutil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                              style: isVanishMode?TextStyle(fontSize: 12, color: Colors.grey):TextStyle(fontSize: 13, color: Colors.white),
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
                    Icons.videocam,
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
              // IconButton(
              //     onPressed: () {
              //     },
              //     icon: Icon(
              //       Icons.more_vert,
              //       color: Colors.white,
              //     )),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.white),
                onSelected: (String value) {
                  if (value == 'clear_chat') {
                    APIs.clearAllmessages(widget.user);
                  }
                  else if (value == 'translator') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Translator(user:widget.user,),));
                  }
                  else if (value == 'message_scheduler') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>ScheduledMessageScreen(user: widget.user)));
                  }
                  else if (value == 'Make_pdf') {
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>SplashScreenImagetopdf()));
                  }
                  else if (value == 'block') {
                    _showBlockConfirmationDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      value: 'clear_chat',
                      child: Text('Clear Chat'),
                    ),
                    PopupMenuItem(
                      value: 'message_scheduler',
                      child: Text('Scheduler'),
                    ),
                    PopupMenuItem(
                      value: 'translator',
                      child: Text('Translator'),
                    ),
                    PopupMenuItem(
                      value: 'Make_pdf',
                      child: Text('Image to PDF'),
                    ),
                    PopupMenuItem(
                      value: 'block',
                      child: Text('Block'),
                    ),
                  ];
                },
              ),
            ],
          );
        },
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

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: isVanishMode ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: isVanishMode
                    ? BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                  style: BorderStyle.solid,
                )
                    : BorderSide.none,
              ),
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
                      color: isVanishMode ? Colors.white : Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        setState(() {
                          if (showemoji) showemoji = !showemoji;
                        });
                      },
                      style: TextStyle(
                        color: isVanishMode ? Colors.white : Colors.black, // Set text color
                      ),
                      controller: _textcontroller,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: "Type Something...",
                        hintStyle: isVanishMode ? TextStyle(color: Colors.white):TextStyle(color: Colors.blueAccent),
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
                      color:isVanishMode ? Colors.white : Colors.blueAccent,
                      size: 26,
                    ),
                  ),
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
                      color: isVanishMode ? Colors.white : Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
            elevation: 3,
            onPressed: () {
              final String message = _textcontroller.text.trim();
              if (message.isNotEmpty) {
                if (list.isEmpty) {
                  if (!containsAbusiveWords(message)) {
                    // If no abusive words, send the message
                    APIs.sendFirstMessage(widget.user, message, Type.text);
                  }
                  else {
                    // Handle abusive words (e.g., show warning)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Warning"),
                          // backgroundColor: Colors.lightBlue.shade50,
                          content: Text(
                            "Your message contains abusive words. Please refrain from using such language.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  // On first message
                }
                else {
                  // Check for abusive words
                  if (!containsAbusiveWords(message)) {
                    // If no abusive words, send the message
                    APIs.sendMessage(widget.user, message, Type.text);
                  } else {
                    // Handle abusive words (e.g., show warning)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Warning"),
                          // backgroundColor: Colors.lightBlue.shade50,
                          content: Text(
                            "Your message contains abusive words. Please refrain from using such language.",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
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

  bool containsAbusiveWords(String text) {
    // List of abusive words (add your own list here)
    List<String> abusiveWords = [
      "आंड़","sex","sexy","breast","teri maa ki", "testicles","aand", "आँड", "bahenchod", "बहनचोद", "sisterfucker", "behenchod", "बेहेनचोद", "sisterfucker", "bhenchod", "भेनचोद", "sisterfucker", "bhenchodd", "भेनचोद", "sisterfucker", "b.c.", "बहनचोद", "sisterfucker", "bc", "बहनचोद", "bakchod", "बकचोद", "blabbermouth", "bakchodd", "बकचोद", "blabbermouth", "bakchodi", "बकचोदी", "blabbering", "bevda", "बेवड़ा", "alcoholic", "bewda", "बेवड़ा", "alcoholic", "bevdey", "बेवड़े", "alcoholic", "bewday", "बेवड़े", "alcoholic", "bevakoof", "बेवकूफ", "idiot", "bevkoof", "बेवकूफ", "bevkuf", "बेवकूफ", "bewakoof", "बेवकूफ", "bewkoof", "बेवकूफ", "idiot", "bewkuf", "बेवकूफ", "bhadua", "भड़ुआ", "pimp", "bhaduaa", "भड़ुआ", "bhadva", "भड़वा", "bhadvaa", "भड़वा","bhadwa", "भड़वा", "bhadwaa", "भड़वा","bhosada", "भोसड़ा", "pussy", "bhosda", "भोसड़ा", "pussy", "bhosdaa", "भोसड़ा", "bhosdike", "भोसड़ीके","bhonsdike", "भोसड़ीके","bsdk", "भोसड़ीके", "bhosdike", "b.s.d.k", "भोसड़ीके", "bhosdike", "bhosdiki", "भोसड़ीकी","bhosdiwala", "भोसड़ीवाला", "bhosdiwale", "भोसड़ीवाले","Bhosadchodal", "भोसरचोदल", "pussy", "fucker", "Bhosadchod", "भोसदचोद", "pussy", "fucker", "Bhosadchodal", "भोसड़ाचोदल", "pussy", "fucker", "Bhosadchod", "भोसड़ाचोद", "pussy", "fucker", "babbe", "बब्बे", "boobs", "babbey", "बब्बे", "boobs", "bube", "बूबे", "boobs", "bubey", "बूबे", "boobs", "bur", "बुर", "pussy", "burr", "बुर", "pussy", "buurr", "बुर", "pussy", "buur", "बुर", "pussy", "charsi", "चरसी", "druggie", "chooche", "चूचे", "nipples", "choochi", "चूची", "nipple", "chuchi", "चुची", "nipple", "chhod", "चोद", "fuck", "chod", "चोद", "fucker", "chodd", "चोद", "fucked", "chudne", "चुदने", "fucking", "chudney", "चुदने", "fucking", "chudwa", "चुदवा", "fucked", "chudwaa", "चुदवा", "fucked", "chudwane", "चुदवाने","fuck", "chudwaane", "चुदवाने", "choot", "चूत", "pussy", "chut", "चूत", "pussy", "chute", "चूत", "pussy", "chutia", "चूतिया", "pussy", "chutiya", "चुटिया", "pussy", "chutiye", "चूतिये", "pussy", "chuttad", "चुत्तड़", "ass", "chutad", "चूत्तड़", "ass", "dalaal", "दलाल", "pimp", "dalal", "दलाल", "pimp", "dalle", "दलले", "dalley", "दलले","fattu", "फट्टू", "timid", "fearful", "gadha", "गधा", "donkey", "gadhe", "गधे", "donkey", "gadhalund", "गधालंड", "penis", "donkey", "gaand", "गांड", "arse", "gand", "गांड", "arse", "gandu", "गांडू", "asshole", "gandfat", "गंडफट", "asshole", "gandfut", "गंडफट", "asshole", "gandiya", "गंडिया", "asshole", "gandiye", "गंडिये", "asshole", "goo", "गू", "shit", "gu", "गू", "shit", "gote", "गोटे", "testicles", "gotey", "गोटे","gotte", "गोटे", "hag", "हग","haggu", "हग्गू", "excreta", "faeces", "hagne", "हगने", "hagney", "हगने", "harami", "हरामी", "bastard", "haramjada", "हरामजादा", "bastard", "haraamjaada", "हरामजादा", "bastard", "haramzyada", "हरामज़ादा", "bastard", "haraamzyaada", "हरामज़ादा", "bastard", "haraamjaade", "हरामजादे", "bastard", "haraamzaade", "हरामज़ादे", "bastard", "haraamkhor", "हरामखोर", "useless", "haramkhor", "हरामखोर", "useless", "jhat", "झाट", "pubic", "hair", "jhaat", "झाट", "pubic", "hair", "jhaatu", "झाटू", "pubic", "hair", "jhatu", "झाटू", "pubic", "hair", "kutta", "कुत्ता", "dog", "kutte", "कुत्ते", "dog", "kuttey", "कुत्ते", "kutia", "कुतिया", "bitch", "kutiya", "कुतिया", "bitch", "kuttiya", "कुतिया", "bitch", "kutti", "कुत्ती", "bitch", "landi", "लेंडी", "landy", "लेंडी", "dog", "shit", "laude", "लोड़े", "dick", "laudey", "लौड़े", "dick", "laura", "लौड़ा", "dick", "lora", "लोड़ा", "dick", "lauda", "लौडा", "dick", "ling", "लिंग", "loda", "लोडा", "dick", "lode", "लोडे", "dick", "lund", "लंड", "dick", "launda", "लौंडा", "dick", "lounde", "लौंडे","laundey", "लौंडे", "dick", "laundi", "लौंडी", "prostitute", "loundi", "लौंडी", "prostitute", "laundiya", "लौंडिया", "prostitute", "loundiya", "लौंडिया", "prostitute", "lulli", "लुल्ली", "penis", "maar", "मार", "hit", "/", "kill", "maro", "मारो", "hit", "now", "marunga", "मारूंगा", "kill", "madarchod", "मादरचोद", "motherfucker", "madarchodd", "मादरचोद", "motherfucker", "madarchood", "मादरचोद", "motherfucker", "madarchoot", "मादरचूत", "mother’s", "cunt", "madarchut", "मादरचुत", "mother’s", "cunt", "m.c.", "मादरचोद","motherfucker", "mc", "मादरचोद", "motherfucker", "mamme", "मम्मे", "boobs", "mammey", "मम्मे", "boobs", "moot", "मूत", "piss", "/", "pee", "mut", "मुत", "piss", "/", "pee", "mootne", "मूतने", "to", "piss", "/", "pee", "mutne", "मुतने", "piss", "/", "pee", "mooth", "मूठ", "masturbate", "muth", "मुठ", "masturbate", "nunni", "नुननी", "small", "sized", "penis", "nunnu", "नुननु", "small", "sized", "penis", "paaji", "पाजी", "idiot", "paji", "पाजी", "idiot", "pesaab", "पेसाब", "piss", "pesab", "पेसाब", "piss", "peshaab", "पेशाब", "piss", "peshab", "पेशाब", "piss", "pilla", "पिल्ला", "pillay", "पिल्ले", "pille", "पिल्ले", "pilley", "पिल्ले", "pisaab", "पिसाब", "piss", "pisab", "पिसाब", "piss", "pkmkb", "abusive", "hashtag", "phrase", "porkistan", "पोरकिस्तान", "abusive", "word", "Pakistan", "raand", "रांड", "slut", "rand", "रांड", "slut", "randi", "रंडी", "slut", "randy", "रंडी", "slut", "suar", "सुअर", "pig", "suar", "सूअर", "pig", "tatte", "टट्टे", "faeces", "tatti", "टट्टी", "faeces", "tatty", "टट्टी", "faeces", "ullu", "उल्लू", "idiot"
    ];

    // Check if the text contains any abusive words
    for (String word in abusiveWords) {
      if (text.toLowerCase().contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
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


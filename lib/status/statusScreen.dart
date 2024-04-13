import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/status/statusViewer.dart';
import 'package:lets_chat/widgets/status_user_card.dart';

class Status_Screen extends StatefulWidget {
  final ChatUser user;
  const Status_Screen({Key? key, required this.user}) : super(key: key);

  @override
  State<Status_Screen> createState() => _Status_ScreenState();
}

class _Status_ScreenState extends State<Status_Screen> {
  bool _isuploading = false;
  List<ChatUser> list=[];
  //for storing search items
  final List<ChatUser> _searchlist=[];
  //for storing search status`
  bool _isSearching  = false;
  List<String> imageUrls = []; // List to store uploaded image URLs
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching?TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Enter Name...",
            hintStyle: TextStyle(color: Colors.white),
          ),
          autofocus: true,
          style: TextStyle(fontSize: 17,letterSpacing: 0.5,color: Colors.white),
          cursorColor: Colors.white,
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
        ):Text("Status"),
        leading: IconButton(
            onPressed: () async {
              final XFile? photo = await ImagePicker()
                  .pickImage(source: ImageSource.camera);
            },
            icon: Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 26,
            )
        ),

        actions: [
          IconButton(onPressed: () {
            setState(() {
              _isSearching=!_isSearching;
            });
          }, icon: Icon(_isSearching?CupertinoIcons.clear_circled_solid:Icons.search,size: 26,)),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final List<XFile> photos =
          await ImagePicker().pickMultiImage();
          if (photos.isNotEmpty) {
            for (var i in photos) {
              // Upload image and get URL
              String imageUrl = await uploaddata(widget.user, File(i.path));
              // Add URL to list
              imageUrls.add(imageUrl);
              Dialogs.showSnackbar(context, "Status Updated Successfully");
              setState(() {
                _isuploading = true;
              });
            }
          }
        },
        shape: StadiumBorder(),
        child: Icon(Icons.camera_alt_rounded,size: 30,color: Colors.white,),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0.8,
            margin: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: InkWell(
              onTap: () async {
                if(imageUrls.isNotEmpty){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewScreen(imageUrls: imageUrls),
                    ),
                  );
                }
                else {
                  final List<XFile> photos =
                  await ImagePicker().pickMultiImage();
                  if (photos.isNotEmpty) {
                    for (var i in photos) {
                      // Upload image and get URL
                      String imageUrl = await uploaddata(
                          widget.user, File(i.path));
                      // Add URL to list
                      imageUrls.add(imageUrl);
                      setState(() {
                        _isuploading = true;
                      });
                    }
                  }
                }
              },
              child: ListTile(
                leading: Stack(
                  children: [
                    _isuploading?Container(
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
                ):
                    ClipRRect(
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
                    if(_isuploading==false)
                    Positioned(
                      bottom: -13,
                      right: -34,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: MaterialButton(
                          onPressed: () async {
                            final List<XFile> photos =
                            await ImagePicker().pickMultiImage();
                            if (photos.isNotEmpty) {
                              for (var i in photos) {
                                // Upload image and get URL
                                String imageUrl = await uploaddata(widget.user, File(i.path));
                                // Add URL to list
                                imageUrls.add(imageUrl);
                                Dialogs.showSnackbar(context, "Status Updated Successfully");
                                setState(() {
                                  _isuploading = true;
                                });

                              }
                            }
                          },
                          child: Icon(Icons.add, color: Colors.white,size: 16,),
                          shape: CircleBorder(),
                          color: Colors.blueAccent,
                          elevation: 1,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text("My Status"),
                subtitle: _isuploading?Text("Tap to view status update"):Text("Tap to add status update"),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text("Recent Updates"),
          ),
          Expanded(
            child: StreamBuilder(
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
                                    return StatusUserCard(
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
        ],
      ),

    );
  }

  Future<String> uploaddata(ChatUser chatUser, File file) async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("Status")
        .child(APIs.user.uid)
        .putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();
    return imageUrl;
  }
}
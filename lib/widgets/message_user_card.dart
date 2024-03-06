import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/helper/my_date_util.dart';
import 'package:lets_chat/main.dart';
import 'package:lets_chat/models/message.dart';

class Messagecard extends StatefulWidget {
  final Message message;
  const Messagecard({super.key, required this.message});

  @override
  State<Messagecard> createState() => _MessagecardState();
}

class _MessagecardState extends State<Messagecard> {
  @override
  Widget build(BuildContext context) {
    bool isMe=APIs.user.uid == widget.message.fromID;
    return InkWell(
      onLongPress: (){
        _showbottomsheet(isMe);
      },
      child:isMe? _greenmessage()
          : _bluemessage(),
    );
  }

  Widget _bluemessage() {
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.Text?15:5),
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: widget.message.type==Type.Text?
            Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ):ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                width: 200,
                height: 300,
                imageUrl: widget.message.msg,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                )),
                errorWidget: (context, url, error) => CircleAvatar(child: const Icon(Icons.image,size: 70,)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            MyDateutil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

  Widget _greenmessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            if(widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.lightBlue,
                size: 20,
              ),
            SizedBox(
              width: 3,
            ),
            Text(
              MyDateutil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.Text?15:5),
            margin: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.lightGreen.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.lightGreen),
            ),
            child: widget.message.type==Type.Text?
            Text(
              widget.message.msg,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ):ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                width: 200,
                height: 300,
                imageUrl: widget.message.msg,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )),
                errorWidget: (context, url, error) => CircleAvatar(child: const Icon(Icons.image,size: 70,)),
              ),
            ),
          ),
        ),
      ],
    );
  }
  saveNetworkImage() async {
    var response = await Dio().get(
        widget.message.msg,
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "Let's Chat");
    log('result:$result');
  }

  void _showbottomsheet(bool isMe){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_){
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.Text
                  ?
              //copy option
              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.message.msg))
                        .then((value) {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                      Dialogs.showSnackbar(context, 'Text Copied!');
                    });
                  })
                  :
              //save option
              _OptionItem(
                  icon: const Icon(Icons.download_rounded, color: Colors.blue, size: 26),
                  name: 'Save Image',
                  onTap: (){
                    saveNetworkImage();
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context, 'Image Saved succesully!');
                  }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              // Image view option
              if (widget.message.type == Type.image)
              _OptionItem(
                icon: const Icon(Icons.image_rounded, color: Colors.blue, size: 26),
                name: 'View Image',
                onTap: () {
                  // Call a method to view the image
                  Navigator.pop(context);
                  _showImageView(widget.message.msg);
                },
              ),

              //edit option
              if (widget.message.type == Type.Text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      Navigator.pop(context);
                      await APIs.deleteMessage(widget.message);
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                  'Sent At: ${MyDateutil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateutil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
              left: 24, right: 24, top: 20, bottom: 10),

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),

          //title
          title: Row(
            children: const [
              Icon(
                Icons.message,
                color: Colors.blue,
                size: 28,
              ),
              Text(' Update Message')
            ],
          ),

          //content
          content: TextFormField(
            initialValue: updatedMsg,
            maxLines: null,
            onChanged: (value) => updatedMsg = value,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),

          //actions
          actions: [
            //cancel button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                )),

            //update button
            MaterialButton(
                onPressed: () {
                  //hide alert dialog
                  Navigator.pop(context);
                  APIs.updateMessage(widget.message, updatedMsg);
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ))
          ],
        ));
  }

  void _showImageView(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }

}
//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}

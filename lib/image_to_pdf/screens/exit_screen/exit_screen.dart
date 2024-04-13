import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lets_chat/image_to_pdf/constant/constant.dart';
import 'package:lets_chat/image_to_pdf/logic/logic.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExitScreen extends StatefulWidget {
  const ExitScreen({Key? key}) : super(key: key);

  @override
  State<ExitScreen> createState() => _ExitScreenState();
}

class _ExitScreenState extends State<ExitScreen> {
  
  TextEditingController controller=TextEditingController();
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[themeColor1, themeColor2],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  final data=Get.find<Logic>();
  @override
  Widget build(BuildContext context) {
    var width =MediaQuery.of(context).size.width;
    return SafeArea(
        child:Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0.5,
            title: Text("Save File",
              style: TextStyle(foreground: Paint()..shader = linearGradient),
            ),
            leading: IconButton(onPressed: ()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back_ios,color: themeColor2,),),
          ),
          body:Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04,vertical: width *0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.008,vertical: width * 0.008),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.02),
                    gradient:const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        stops: [0.1, 0.5],
                        colors: [themeColor1,themeColor2]
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                    color: Colors.white,
                      borderRadius: BorderRadius.circular(width * 0.01)
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04,),
                        hintText: "Untitled",
                        suffixText: ".pdf",
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(color: Colors.grey,thickness: 1.2,),
                ),
                ListTile(
                  onTap: ()=>OpenFilex.open(data.pdf.value!.path),
                  leading: const Icon(Icons.remove_red_eye_outlined),
                  title: Text("See Preview",style: TextStyle(foreground: Paint()..shader = linearGradient),),
                  trailing:const  Icon(Icons.arrow_forward_ios_outlined),
                ),
                const Divider(),
                ListTile(
                  onTap: () async {
                    if(controller.text.isNotEmpty){
                      await saveFile(data.pdf.value!.path);
                      Fluttertoast.showToast(msg: "File successfully saved");
                    }
                    else {
                      Fluttertoast.showToast(msg: "Please give the name to your file");
                    }
                  },
                  leading: const Icon(Icons.save_alt),
                  title: Text("Save File", style: TextStyle(foreground: Paint()..shader = linearGradient)),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                ),
                const Divider(),
                ListTile(
                  onTap: ()=>shareFile(data.pdf.value!.path),
                  leading: const Icon(Icons.share),
                  title: Text("Share File",style: TextStyle(foreground: Paint()..shader = linearGradient),),
                  trailing:const Icon(Icons.arrow_forward_ios_outlined),
                ),

              ],
            ),
          ) ,
        )
    );
  }
  Future<void> shareFile(String path) async {
    try {
      // Get temporary directory
      final directory = await path_provider.getTemporaryDirectory();
      final filePath = '${directory.path}/${controller.text}.pdf';

      // Save the PDF file to the temporary directory
      await File(filePath).writeAsBytes(data.pdf.value!.readAsBytesSync());

      // Share the saved file using share_plus
      await Share.shareFiles(
        [filePath],
        text: 'Image to PDF',
        subject: "${controller.text}.pdf",
        mimeTypes: ['application/pdf'],
      );
    } catch (e) {
      log("Error sharing file: $e");
      Fluttertoast.showToast(msg: "Failed to share file");
    }
  }

  Future<void> saveFile(String path) async {
    try {
      final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/${controller.text}.pdf';
      await File(filePath).writeAsBytes(data.pdf.value!.readAsBytesSync());
      Fluttertoast.showToast(msg: "File successfully saved");
    } catch (e) {
      log("Error saving file: $e");
      Fluttertoast.showToast(msg: "Failed to save file");
    }
  }



}

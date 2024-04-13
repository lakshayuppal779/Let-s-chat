import 'package:flutter/material.dart';
import 'package:lets_chat/API/apis.dart';
import 'package:lets_chat/helper/dialogs.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:translator/translator.dart';
import 'package:lets_chat/models/message.dart';


class Translator extends StatefulWidget {
  final ChatUser user;
  const Translator({super.key, required this.user});

  @override
  State<Translator> createState() => _TranslatorState();
}

class _TranslatorState extends State<Translator> {
  var languages=['hindi','english','punjabi','french','german','italian','japanese','chinese','korean','malayalam','marathi','tamil','telugu','urdu','arabic'];
  var originlanguage="From";
  var destinationlanguage="To";
  var output="";
  TextEditingController lang=TextEditingController();

  void translate(String src,String dest,String input)async{
    GoogleTranslator translator = new GoogleTranslator();
    var translation = await translator.translate(input, from: src, to: dest);
  setState(() {
    output=translation.text.toString();
  });
  if(src=='--'|| dest=='--'){
    setState(() {
      output="Fail to translate";
    });
   }
  }
  String getLanguageCode(String language){
    if(language=='english'){
      return 'en';
    }
    else if(language=='hindi'){
      return 'hi';
     }
    else if(language=='punjabi'){
      return 'pa';
     }
    else if(language=='french'){
      return 'fr';
    }
    else if(language=='german'){
      return 'de';
    }
    else if(language=='italian'){
      return 'it';
    }
    else if(language=='japanese'){
      return 'ja';
    }
    else if(language=='korean'){
      return 'ko';
    }
    else if(language=='chinese'){
      return 'zh-CN';
    }
    else if(language=='malayalam'){
      return 'ml';
    }
    else if(language=='marathi'){
      return 'mr';
    }
    else if(language=='tamil'){
      return 'ta';
    }
    else if(language=='urdu'){
      return 'ur';
    }
    else if(language=='telugu'){
      return 'te';
    }
    else if(language=='arabic'){
      return 'ar';
    }
    return '--';
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Language translator"),
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(output.isNotEmpty) {
              Navigator.pop(context);
              APIs.sendMessage(
                  widget.user, output, Type.text);
            }
          },
          shape: StadiumBorder(),
          child: Icon(Icons.send,size: 30,color: Colors.white,),
          backgroundColor: Colors.blueAccent,
        ),// You can adjust the shade as needed
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: SizedBox(
                height: 700,
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton(
                            items:languages.map((String dropDownStringItem){
                              return DropdownMenuItem(child: Text(dropDownStringItem,style: TextStyle(color: Colors.blueAccent),),value: dropDownStringItem,);
                            }).toList(),
                            focusColor: Colors.blueAccent,
                            iconDisabledColor: Colors.blueAccent,
                            iconEnabledColor:Colors.blueAccent,
                            dropdownColor: Colors.white,
                            hint: Text(originlanguage,style: TextStyle(color: Colors.blueAccent,fontSize: 18),),
                            icon: Icon(Icons.keyboard_arrow_down),
                            onChanged: (String? value){
                              setState(() {
                                originlanguage=value!;
                              });
                            },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Icon(Icons.arrow_right_alt_rounded,size: 28,),
                        SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                          items:languages.map((String dropDownStringItem){
                            return DropdownMenuItem(child: Text(dropDownStringItem,style: TextStyle(color: Colors.blueAccent),),value: dropDownStringItem,);
                          }).toList(),
                          focusColor: Colors.blueAccent,
                          iconDisabledColor: Colors.blueAccent,
                          iconEnabledColor:Colors.blueAccent,
                          dropdownColor: Colors.white,
                          hint: Text(destinationlanguage,style: TextStyle(color: Colors.blueAccent,fontSize: 18),),
                          icon: Icon(Icons.keyboard_arrow_down),
                          onChanged: (String? value){
                            setState(() {
                              destinationlanguage=value!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 320,
                        child: TextFormField(
                          cursorColor: Colors.blueAccent,
                          autofocus: false,
                          style: TextStyle(
                            color: Colors.blueAccent
                          ),
                          decoration: InputDecoration(
                            labelText: "Please enter your text...",
                            labelStyle: TextStyle(color: Colors.blueAccent,fontSize: 16),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 1,
                              )
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blueAccent,
                                  width: 2,
                                )
                            ),
                            errorStyle: TextStyle(color: Colors.redAccent,fontSize: 15),
                          ),
                          controller: lang,
                          validator: (value){
                            if(value==null || value.isEmpty){
                              Dialogs.showSnackbar(context, "Please enter text to translate");
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: (){
                            translate(getLanguageCode(originlanguage),getLanguageCode(destinationlanguage),lang.text.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: ContinuousRectangleBorder(),
                          ),
                          child: Text(
                            'Translate',
                            style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text("\n $output",style: TextStyle(color: Colors.blueAccent,fontSize: 20,fontWeight: FontWeight.bold),)
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

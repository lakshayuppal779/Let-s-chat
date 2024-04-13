import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:lets_chat/notesMaking/cubit/Group.cubit.dart';
import 'package:lets_chat/notesMaking/cubit/Note.cubit.dart';
import 'package:lets_chat/screens/splashscreen.dart';
import 'firebase_options.dart';

late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: [SystemUiOverlay.top]);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    _initializefirebase();
    // Initialize your cubits
    final NoteCubit noteCubit = NoteCubit();
    final GroupCubit groupCubit = GroupCubit();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<NoteCubit>.value(
            value: noteCubit,
          ),
          BlocProvider<GroupCubit>.value(
            value: groupCubit,
          ),
        ],
        child: const MyApp(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      }
    });
  });
}

_initializefirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For sending message notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('\n notification channel result: $result');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Let's Chat",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 21, fontWeight: FontWeight.w400),
        ),
      ),
      home: Splashscreen(),
    );
  }
}

import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(.8),
      behavior: SnackBarBehavior.floating,
      duration: duration, // Set the duration here
    ));
  }

  static void showProgressbar(BuildContext context) {
    showDialog(context: context, builder: (_)=> Center(child: CircularProgressIndicator()));
  }
}

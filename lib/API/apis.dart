import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class APIs {
  static User get user => FirebaseAuth.instance.currentUser!;
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '',
      );
  //to check user exits in firestore or not
  static Future<bool> Userexits() async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get())
        .exists;
  }

  //for profile screen data update changes
  static Future<void> updateuserinfo() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'name': me.name,
      'about': me.about,
      'image': me.image,
    });
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists
      log('user exists: ${data.docs.first.data()}');
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesn't exists
      return false;
    }
  }

  //for getting user info
  static Future<void> getselfinfo() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if(user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getselfinfo());
      }
    });
  }

  //create user if not exits in firestore
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hey,I'm using let's Chat!",
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        email: user.email.toString(),
        pushToken: '');
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return FirebaseFirestore.instance
        .collection('users')
        .where('id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds) //because empty list throws an error
        .snapshots();         // .where('id', isNotEqualTo: user.uid)
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  //for getting conversation ID
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllmessages(
      ChatUser user) {
    return FirebaseFirestore.instance
        .collection("chats/${getConversationID(user.id)}/messages/")
        .snapshots();
  }
  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    return FirebaseFirestore.instance
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
  // Clear all messages
  static Future<void> clearAllmessages(ChatUser user) async {
    // Get a reference to the collection
    final collectionRef = FirebaseFirestore.instance
        .collection("chats/${getConversationID(user.id)}/messages/");

    // Get all documents in the collection
    final documents = await collectionRef.get();

    // Iterate over each document and delete it
    for (var document in documents.docs) {
      await collectionRef.doc(document.id).delete();
    }
  }

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseFirestore.instance.collection('chats/${getConversationID(chatUser.id)}/messages/');
    if (type == Type.pdf) {
      await sendMessageWithPDF(chatUser, File(msg));
      return;
    }
    final Message message = Message(
      toID: chatUser.id,
      msg: msg,
      read: '',
      type: type,
      sent: time,
      fromID: user.uid,
      isVanishMode: await isVanishMode(me,chatUser),
    );
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, me, type == Type.text ? msg : 'image'));

  }

  static Future<void> sendMessageWithPDF(ChatUser chatUser, File pdfFile) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseFirestore.instance.collection('chats/${getConversationID(chatUser.id)}/messages/');

      // Upload the PDF file to Firebase Storage
      final String fileName = '$time.pdf';
      final Reference storageRef = FirebaseStorage.instance.ref().child('pdfs/$fileName');
      final UploadTask uploadTask = storageRef.putFile(pdfFile);
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL of the uploaded PDF
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create a message object with PDF download URL
      final Message message = Message(
        toID: chatUser.id,
        msg: downloadUrl,
        read: '',
        type: Type.pdf, // Set the type as PDF
        sent: time,
        fromID: user.uid,
        isVanishMode: await isVanishMode(me,chatUser),
      );
      // Send the message to Firestore
      await ref.doc(time).set(message.toJson());
      // Send push notification
      sendPushNotification(chatUser,me,'PDF document');

    } catch (e) {
      // Handle errors
      log('Error sending PDF: $e');
    }
  }


  //delete vanish messages
  static Future<void> deleteVanishMessage(Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toID)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await FirebaseStorage.instance.refFromURL(message.msg).delete();
    }
  }

  // Delete a specific message
  static Future<void> deleteMessage(Message message) async {
    try {
      // Check if the message contains "You deleted a chat"
      if (message.msg == 'You deleted a chat') {
        // If the message contains the specific text, permanently delete it from Firestore
        await FirebaseFirestore.instance
            .collection('chats/${getConversationID(message.toID)}/messages/')
            .doc(message.sent)
            .delete();
        log('Message deleted permanently: ${message.toJson()}');
      }
      else{
        // If the message does not contain the specific text, update it to "You deleted a chat"
        await FirebaseFirestore.instance
            .collection('chats/${getConversationID(message.toID)}/messages/')
            .doc(message.sent)
            .update({
          'msg': 'You deleted a chat'
        });
        log('Message updated: ${message.toJson()}');
      }

    } catch (e) {
      // Handle errors
      log('Error deleting message: $e');
    }
  }
  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toID)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg}
    );
  }

  //for updating message read unread status
  static Future<void> updateMessageReadStatus(Message message) async {
    FirebaseFirestore.instance
        .collection("chats/${getConversationID(message.fromID)}/messages/")
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserinfo(
      ChatUser chatuser){
    return FirebaseFirestore.instance
        .collection("users")
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken()async{
      await fmessaging.requestPermission();
      await fmessaging.getToken().then((t){
        if(t!=null){
          me.pushToken=t;
          log('Push token: $t');
        }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('Got a message whilst in the foreground!');
        log('Message data: ${message.data}');

        if (message.notification != null) {
          log('Message also contained a notification: ${message.notification}');
        }
      });
  }

  // Function to mute/unmute notifications for a user's known users
  static Future<void> toggleMuteNotification(ChatUser user, ChatUser targetUser, bool isMuted) async {
    // Update the mute notification status for the target user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .update({'muteNotification': isMuted});
  }

// Function to check if notifications are muted for a specific known user
  static Future<bool> isNotificationMuted(ChatUser user, ChatUser targetUser) async {
    // Get the mute notification status for the target user
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('muteNotification')) {
        return data['muteNotification'];
      }
    }
    return false;
  }
  // Function to send push notification
  static Future<void> sendPushNotification(ChatUser chatUser, ChatUser targetUser, String msg) async {
    try {
      // Check if notifications are muted for the recipient
      final isMuted = await isNotificationMuted(chatUser, targetUser);
      if (isMuted) {
        // If notifications are muted, don't send the push notification
        log('Notifications are muted for user ${chatUser.name}.');
        return;
      }
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
          'key=AAAAJoeIBgY:APA91bEgRzpaKLM80veINcNdK-mr1MVVr1cZhQjUfnqa8_7yULEFkIIICo1oMk6VhAbRnWGvzWo1kQU17sWL7ptqwQulFD3JR3JKpeoCwK4X9AX778MxWoBjjefYgtphZYVi6qS6FPNF'
        },
        body: jsonEncode(body),
      );
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // scheduled message
  static Future<void> sendScheduledMessage(ChatUser chatUser, String message, DateTime scheduledDateTime) async {
    final currentTime = DateTime.now();
    final timeDifference = scheduledDateTime.difference(currentTime);

    // If the scheduled time is in the future
    if (timeDifference.isNegative) {
      throw Exception("Scheduled time must be in the future");
    }

    // Delay the sending of the message
    await Future.delayed(timeDifference);

    // Send the message
    sendMessage(chatUser, message, Type.text);
  }

  // Delete a chat user from the current user's list of my_users
  static Future<void> deleteChatUser(ChatUser chatUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(chatUser.id)
          .delete();
      log('Chat user ${chatUser.name} deleted successfully.');
    } catch (e) {
      // Handle errors
      log('Error deleting chat user: $e');
    }
  }

  static Future<void> toggleChatLock(ChatUser user, ChatUser targetUser, bool isChatLocked) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .update({'chat_lock': isChatLocked});
  }

  static Future<bool> isChatLocked(ChatUser user, ChatUser targetUser) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('chat_lock')) {
        return data['chat_lock'];
      }
    }
    return false;
  }

  static Future<void> toggleVanishMode(ChatUser user, ChatUser targetUser, bool isvanishmode) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .update({'vanish_mode': isvanishmode});
  }

  static Future<bool> isVanishMode(ChatUser user, ChatUser targetUser) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .collection('my_users')
        .doc(targetUser.id)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey('vanish_mode')) {
        return data['vanish_mode'];
      }
    }
    return false;
  }
}

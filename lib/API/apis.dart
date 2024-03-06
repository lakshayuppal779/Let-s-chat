import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:lets_chat/models/chat_user.dart';
import 'package:lets_chat/models/message.dart';
import 'package:permission_handler/permission_handler.dart';

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

  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg,Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toID: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromID: user.uid);
    final ref = FirebaseFirestore.instance
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser, type == Type.Text ? msg : 'image'));
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toID)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await FirebaseStorage.instance.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationID(message.toID)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
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

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
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

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAJoeIBgY:APA91bEgRzpaKLM80veINcNdK-mr1MVVr1cZhQjUfnqa8_7yULEFkIIICo1oMk6VhAbRnWGvzWo1kQU17sWL7ptqwQulFD3JR3JKpeoCwK4X9AX778MxWoBjjefYgtphZYVi6qS6FPNF'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
}

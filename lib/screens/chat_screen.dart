import 'package:chat_app/screens/chat_messages.dart';
import 'package:chat_app/screens/new_messages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen  extends StatefulWidget{
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void setPushNotifications() async{
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }
  @override
 void initState(){
  super.initState();
  setPushNotifications();
  
 }
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('TALKTO'),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();           //to logout from the flutter char
          },
           icon: Icon(Icons.exit_to_app),
           color: Theme.of(context).colorScheme.primary,)
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: const ChatMessages()), //expanded widget takes all the available space
            NewMessages(),
          ],
        )
    ),
    );
  }
}
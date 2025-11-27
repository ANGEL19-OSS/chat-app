
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/messages_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessages extends StatelessWidget{
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;                             //to get  the current user
       return StreamBuilder(                                                    //stream to asyncly get the data fromt the fireabse whenever a chat is like a snapshot then builder is trigger
        stream: FirebaseFirestore.instance.collection('chat').orderBy
        ('createdAt', descending: false).snapshots(),                           //latest message at  the bottom
         builder: (ctx ,  chatSnapshot){
          if(chatSnapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if(!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty){
            return Center(child: Text('No messages found!'),);
          }
          if(chatSnapshot.hasError){
            return Center(child: Text('Something went wrong '),
            );
          }

          final loadedmessages = chatSnapshot.data!.docs;      //getting that data from the snapshot
          return ListView.builder(
            padding: EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,                                          //debug while running the app
            itemCount: loadedmessages.length,
            itemBuilder: (ctx,index)  {
              final chatMessage = loadedmessages[index].data();
              final nextMessage = index + 1 < loadedmessages.length ?
              loadedmessages[index + 1].data() : null;   //to check if there is a next message
              final currentUserId  = chatMessage['userId'];
              final nextUserId = nextMessage != null? nextMessage['userId'] : null;
              final nextuserIssame = nextUserId == currentUserId;

              if(nextuserIssame){
                return MessageBubble.next(message: chatMessage['text'], isMe: user.uid == currentUserId );
              }else{
                return MessageBubble.first(
                  userImage: chatMessage['userImageURL'], 
                  username: chatMessage['username'],
                   message: chatMessage['text'],
                    isMe: user.uid == currentUserId);
              }
            }
             );
         }
         );
  }
}
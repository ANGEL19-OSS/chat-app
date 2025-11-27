import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SplashScreen  extends StatelessWidget{
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('chat-screen'),
        
      ),
      body: Center(
        child: Text('Loading...'),
      )
    );
  }
}
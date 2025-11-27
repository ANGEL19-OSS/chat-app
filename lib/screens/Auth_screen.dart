import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final _firebase = FirebaseAuth.instance;            //a instance object to interact with the backend

class AuthScreen extends StatefulWidget{
  
  @override 
  State<AuthScreen> createState(){
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen>{
  final form = GlobalKey<FormState>();
  var isLogin = true;
  var isEnteredemail = '';
  var isEnteredps = '';
  var _enteredusername =' ';

 File ? _selectedImage;
 var isuploading = false;


  void _submit() async{
     final isvalid = form.currentState!.validate();           //to trigger the validation in the formtextfield

       if(!isvalid || !isLogin && _selectedImage == null){
        return;
       }
     
      form.currentState!.save();             //save triggers the special function in all the formfields
     try{
      setState(() {
        isuploading = true;
      });
     if(isLogin){
             final usercredentials = await _firebase.signInWithEmailAndPassword(
              email: isEnteredemail, password: isEnteredps);                           //login user
              print(usercredentials);
       }else{
      
           final usercredentials =  await _firebase.createUserWithEmailAndPassword(             //createUseremail is a future  function 
           email: isEnteredemail, password: isEnteredps);

          final storageref =  FirebaseStorage.instance.ref().child('user-images').child('${usercredentials.user!.uid}.jpg');   
          await  storageref.putFile(_selectedImage!);    
          final imageURL = await storageref.getDownloadURL();    
          print(imageURL);                                             //to create in the storage in firebase

        await  FirebaseFirestore.instance.collection('users').doc(
              usercredentials.user!.uid).set({
                'username' : _enteredusername,
                'email' : isEnteredemail,
                'imageurl' : imageURL,
                'password' : isEnteredps,
              });
        }
       }on FirebaseException catch (error){
          if(error.code == 'email-already-in-use'){
            
          }
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Authentication Failed')));
          setState(() {
            isuploading =  false;
          });
      }
     
     }
     
  

    Widget build(BuildContext context){
      return Scaffold(
           body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 30,
                      right: 20,
                      bottom: 20,
                      left: 20,
                    ),
                    width: 200,
                    child: Image.asset('assets/images/chat.png'),
                  ),
                  Card(
                    margin: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,             //take only the space required not everthing 
                            children: [
                              if(!isLogin)
                              UserImagePicker(onPickedImage: (pickedImage){
                                 _selectedImage = pickedImage;
                              },),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                ),
                                validator:(value){
                                  if(value == null || value.trim().isEmpty || !value.contains('@')){
                                    return 'Please enter a vaid email address';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                onSaved: (value){
                                  isEnteredemail = value!;
                                },
                              ),
                              if(!isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',          
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if(value ==null || value.trim().length<4){
                                    return 'Please enter at least 4 characters';
                                  }
                                  return null;
                                },
                                onSaved: (value){
                                  _enteredusername = value!;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                ),
                                validator:(value){
                                  if(value == null || value.trim().length<6 ){
                                    return 'Please enter a vaid password';
                                  }

                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                onSaved: (value){
                                  isEnteredps = value!;
                                },
                              ),
                              const SizedBox(height: 12,),
                              
                              if(!isuploading)
                              ElevatedButton
                              (
                                onPressed: (){
                                _submit();           //after the formfields
                              },
                              style: ElevatedButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.primaryContainer),
                               child: Text(isLogin ? 'Login' : 'SignUp')),
                              TextButton(
                                onPressed: (){
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                }, 
                                child: Text(isLogin ? 'Create a account' : 'I already have an account'))
                            ],
                          )),),
                    )
                  )
                ],
              ),
            ),
           ),
      );
    }
}
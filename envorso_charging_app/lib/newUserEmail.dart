import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'newUser.dart';
import 'firstlaunch.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),     
    );
  }
}


// create new user from user input
class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);
  @override
  _AddUser createState() => _AddUser();
}

class _AddUser extends State<AddUser> {

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            Container(
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), 
                  labelText: 'Email',
                ),
              )
            )
          ]
        )
      )
    );
  }
}

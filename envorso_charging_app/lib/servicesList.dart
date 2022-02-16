import 'package:envorso_charging_app/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'mapScreen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Services List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class ServicesList extends StatefulWidget {
  const ServicesList({Key? key}) : super(key: key);
  @override
  _ServicesList createState() => _ServicesList();
}

class _ServicesList extends State<ServicesList> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(

          )
        ));
}}
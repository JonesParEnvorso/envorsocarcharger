import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'enRouteAccountSettings.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class SavedLocations extends StatefulWidget {
  const SavedLocations({Key? key}) : super(key: key);
  @override
  _SavedLocations createState() => _SavedLocations();
}

class _SavedLocations extends State<SavedLocations> {
  @override
  
  

  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(

    );
  }
}
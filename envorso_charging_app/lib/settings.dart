import 'package:flutter/material.dart';
import 'newUserEmail.dart';

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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  _SettingsScreen createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Container(
              child: ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.arrow_back),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(CircleBorder()),
                      padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                      backgroundColor: MaterialStateProperty.all(
                          Color(0xff096B72)), // Button color
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed))
                          return Colors.black; // Splash color
                      })))),
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Settings',
                style: TextStyle(fontSize: 20),
              )),
              Container( 
                child: ElevatedButton(
                  onPressed: () {},
                  child: Icon(Icons.cancel)
                )
              ),
        ],
      ),
    ));
  }
}

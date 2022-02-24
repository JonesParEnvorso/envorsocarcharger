import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings.dart';
import 'mapScreen.dart';

import 'main.dart';
import 'speech_recognition.dart' as speech;

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
      home: const searchPage(),
    );
  }
}

class searchPage extends StatefulWidget {
  const searchPage({Key? key}) : super(key: key);

  @override
  _searchPage createState() => _searchPage();
}

class _searchPage extends State<searchPage> {
  //const _searchPage({Key? key}) : super(key: key);
  @override
  goToSettings(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }
 goToMap(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapScreen()));
  }

  
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => goToSettings(context),
                  icon: Icon(Icons.settings),
                  iconSize: 45,
                ),
                Text('USERNAME FILLER', style: TextStyle(color: Colors.black))
              ],
            )),
        Container(
            padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
            child: Row(children: [
              Container(
                  child: ElevatedButton(
                onPressed: () => goToMap(context),
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
                  }),
                ),
              )),
              // NEED TO DO
              // ON FOCUS ON THIS ELEMENT WHEN SELECTING SEARCH FROM Map PAGE
              // Have Back button go back to map page
              // Mic does nothin
              // make a list of starred then recent locations
              // when location is clicked, it goes to map screen with location focused

              Container(
                  padding: EdgeInsets.all(1),
                  width: 250,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0)),
                    ),
                  )),
              Container(
                  child: ElevatedButton(
                onPressed: () {
                  speech.MyApp;
                },
                child: Icon(Icons.mic),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                  backgroundColor: MaterialStateProperty.all(
                      Color(0xff732015)), // Button color
                  overlayColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.pressed))
                      return Colors.black; // Splash color
                  }),
                ),
              )),
            ])),
            /*Container(
              child: ListView(
                  

              ),
            ),*/
      
      ],
    )));
  }
}

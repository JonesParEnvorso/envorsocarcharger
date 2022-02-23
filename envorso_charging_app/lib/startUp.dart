import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firstlaunch.dart';
import 'mapScreen.dart';

class StartUp extends StatefulWidget {
  const StartUp({Key? key}) : super(key: key);
  @override
  _StartUp createState() => _StartUp();
}

class _StartUp extends State<StartUp> {
  User? user;

  @override
  void initState() {
    super.initState();
    // listen to Auth State changes
    FirebaseAuth.instance
        .authStateChanges()
        .listen((event) => updateUserState(event));
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateUserState(event) {
    setState(() {
      user = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const FirstLaunch();
    } else {
      return const MapScreen();
    }
  }
}

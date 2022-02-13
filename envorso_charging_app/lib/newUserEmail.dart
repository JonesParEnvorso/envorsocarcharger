import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'newUser.dart';
import 'firstlaunch.dart';
import 'package:flutter/gestures.dart';

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
  goToPID(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPID()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ListView(children: <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(30),
          child: const Text(
            'Sign up',
            style: TextStyle(fontSize: 20),
          )),
      Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
            ),
          )),
      Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          )),
      Container(
        child: MyStatefulWidget(),
      ),
      Container(
          height: 50,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ElevatedButton(
            child: const Text('Continue'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xff096B72)),
            ),
            onPressed: () => goToPID(context),
          )),
    ])));
  }
}

class LinkedLabelCheckbox extends StatelessWidget {
  const LinkedLabelCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
          Expanded(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "I agree to the ",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "Terms of Services ",
                    style: TextStyle(color: Color(0xff096B72)),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                TextSpan(text: "and ", style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: Color(0xff096B72),
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                TextSpan(text: ".", style: TextStyle(color: Colors.black))
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return LinkedLabelCheckbox(
      label: 'Linked, tappable label text',
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      value: _isSelected,
      onChanged: (bool newValue) {
        setState(() {
          _isSelected = newValue;
        });
      },
    );
  }
}

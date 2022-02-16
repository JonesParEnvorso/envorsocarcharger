import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'newUser.dart';
import 'firstlaunch.dart';
import 'package:flutter/gestures.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Up',
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
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPID(
                  documentId: curUser,
                )));
  }

  goToLogin(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => FirstLaunch()));
  }

  final newEmail = TextEditingController();
  final newPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _passwordVisible = false;

  late String curUser;

  // firebase function
  void _signUp() async {
    String email = newEmail.text;
    String password = newPassword.text;

    newEmail.clear();
    newPassword.clear();

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    await users
        .add({
          "email": email,
          "password": password,
        })
        .then((value) => curUser = value.id)
        .catchError((error) => print("Failed to add user: $error"));

    goToPID(context);
  } // _signUp

  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      super.initState();

      _passwordVisible = false;
    }

    @override
    void dispose() {
      newEmail.dispose();
      newPassword.dispose();

      super.dispose();
    }

    _validateField(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      return null;
    } // _validateField

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
      Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
                // email
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: newEmail,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateField,
                )),
            Container(
                // password
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: newPassword,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  autocorrect: false,
                  textInputAction: TextInputAction.go,
                  validator: _validateField,
                )),
            // checkbox and agreement stuff
            const MyStatefulWidget(),
          ],
        ),
      ),
      Container(
          // continue
          height: 50,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ElevatedButton(
              child: const Text('Continue'),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff096B72)),
              ),
              onPressed: () {
                // button validation. need to make checkbox work better.
                // currently there is no indication that the box needs to be checked
                if (_formKey.currentState!.validate() && _isSelected) {
                  _signUp();
                }
              })),
      TextButton(
        // back to login
        onPressed: () => goToLogin(context),
        child: const Text('Already have an account?',
            style: TextStyle(color: Color(0xff096B72))),
      ),
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
                const TextSpan(
                    text: "I agree to the ",
                    style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "Terms of Services ",
                    style: const TextStyle(color: Color(0xff096B72)),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                const TextSpan(
                    text: "and ", style: TextStyle(color: Colors.black)),
                TextSpan(
                    text: "Privacy Policy",
                    style: const TextStyle(
                      color: Color(0xff096B72),
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {}),
                const TextSpan(text: ".", style: TextStyle(color: Colors.black))
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

// may have to change this from global at some point
bool _isSelected = false;

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  //bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return LinkedLabelCheckbox(
      label: 'Linked, tappable label text',
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      value: _isSelected,
      onChanged: (v) {
        setState(() {
          _isSelected = !_isSelected;
        });
      },
    );
  }
}

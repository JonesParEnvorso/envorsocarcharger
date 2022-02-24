import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'newUser.dart';
import 'firstlaunch.dart';
import 'userAuth.dart';
import 'firebaseFunctions.dart';

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
  final newEmail = TextEditingController();
  final newPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _passwordVisible = false;

  late String curUser;

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  String uId = '';

  @override
  void initState() {
    super.initState();

    _passwordVisible = false;
  }

  @override
  void dispose() {
    newEmail.clear();
    newPassword.clear();
    newEmail.dispose();
    newPassword.dispose();

    super.dispose();
  }

  goToPID(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPID(
                  uId: uId,
                  email: newEmail.text,
                  password: newPassword.text,
                )));
  }

  goToLogin(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const FirstLaunch()));
  }

  @override
  Widget build(BuildContext context) {
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
                        color: const Color(0xff096B72),
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
              onPressed: () async {
                // button validation. need to make checkbox work better.
                // currently there is no indication that the box needs to be checked
                if (_formKey.currentState!.validate() && _isSelected) {
                  // error checking
                  String? res = await firebaseFunctions.createAccount(
                      newEmail.text, newPassword.text);
                  if (res == '' || res == null) {
                    // do something
                  } else if (res == 'email') {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _signUpAlert(context, 'Email is already in use'));
                  } else if (res == 'weak') {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => _signUpAlert(context,
                            'Weak Password. Need a minimum of six characters'));
                  } else if (res == 'invalid email') {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => _signUpAlert(
                            context, 'Please Enter a valid email'));
                  } else {
                    uId = res;
                    goToPID(context);
                  }
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
    return Row(
      children: <Widget>[
        Expanded(
          child: Checkbox(
            value: value,
            activeColor: Color(0xff096B72),
            onChanged: (bool? newValue) {
              onChanged(newValue!);
            },
          ),
        ),
        Row(children: [
          RichText(
              text: TextSpan(children: [
            const TextSpan(
                text: "I agree to the ", style: TextStyle(color: Colors.black)),
          ])),
          TextButton(
              child: const Text('Terms of Services'),
              style: TextButton.styleFrom(primary: Color(0xff096B72)),
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Terms of Service'),
                      content: const SingleChildScrollView(
                          child: Text(
                        'These are the Terms of Service governing the use of this Service and the agreement that operates between You and the Company. These Terms of Service set out the rights and obligations of all users regarding the use of the Service. Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms of Service. These Terms of Service apply to all visitors, users and others who access or use the Service. By accessing or using the Service You agree to be bound by these Terms of Service. If You disagree with any part of these Terms of Service then You may not access the Service. You represent that you are over the age of 18. The Company does not permit those under 18 to use the Service. Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service. \n\nUser Accounts:\nWhen You create an account with Us, You must provide Us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of Your account on Our Service. You are responsible for safeguarding the password that You use to access the Service and for any activities or actions under Your password, whether Your password is with Our Service or a Third-Party Social Media Service. You agree not to disclose Your password to any third party. You must notify Us immediately upon becoming aware of any breach of security or unauthorized use of Your account. You may not use as a username the name of another person or entity or that is not lawfully available for use, a name or trademark that is subject to any rights of another person or entity other than You without appropriate authorization, or a name that is otherwise offensive, vulgar or obscene.',
                      )),
                      actions: <Widget>[
                        TextButton(
                          style:
                              TextButton.styleFrom(primary: Color(0xff096B72)),
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  )),
          RichText(
              text: TextSpan(children: [
            const TextSpan(text: "and", style: TextStyle(color: Colors.black)),
          ])),
        ]),
        TextButton(
            child: const Text('Privacy Policy.'),
            style: TextButton.styleFrom(primary: Color(0xff096B72)),
            onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Privacy Policy'),
                    content: const SingleChildScrollView(
                        child: Text(
                            'These are the Terms of Service governing the use of this Service and the agreement that operates between You and the Company. These Terms of Service set out the rights and obligations of all users regarding the use of the Service. Your access to and use of the Service is conditioned on Your acceptance of and compliance with these Terms of Service. These Terms of Service apply to all visitors, users and others who access or use the Service. By accessing or using the Service You agree to be bound by these Terms of Service. If You disagree with any part of these Terms of Service then You may not access the Service. You represent that you are over the age of 18. The Company does not permit those under 18 to use the Service. Your access to and use of the Service is also conditioned on Your acceptance of and compliance with the Privacy Policy of the Company. Our Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your personal information when You use the Application or the Website and tells You about Your privacy rights and how the law protects You. Please read Our Privacy Policy carefully before using Our Service. User Accounts When You create an account with Us, You must provide Us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of Your account on Our Service. You are responsible for safeguarding the password that You use to access the Service and for any activities or actions under Your password, whether Your password is with Our Service or a Third-Party Social Media Service. You agree not to disclose Your password to any third party. You must notify Us immediately upon becoming aware of any breach of security or unauthorized use of Your account.  You may not use as a username the name of another person or entity or that is not lawfully available for use, a name or trademark that is subject to any rights of another person or entity other than You without appropriate authorization, or a name that is otherwise offensive, vulgar or obscene.',
                            style: TextStyle(color: Color(0xff096B72)))),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(primary: Color(0xff096B72)),
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                )),
      ],
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

Widget _signUpAlert(BuildContext context, String content) {
  return AlertDialog(
    title: const Text('Sign-up Error'),
    content: Text(content),
    actions: <Widget>[
      TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close')),
    ],
  );
}

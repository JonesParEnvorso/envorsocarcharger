import 'package:envorso_charging_app/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'mapScreen.dart';
import 'servicesList.dart';
import 'settings.dart';
import 'userAuth.dart';

class FirstLaunch extends StatefulWidget {
  const FirstLaunch({Key? key}) : super(key: key);
  @override
  _FirstLaunch createState() => _FirstLaunch();
}

class _FirstLaunch extends State<FirstLaunch> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _passwordVisible = false;
  UserAuth userAuth = UserAuth();

  String emailMessage = '';
  String passwordMessage = '';

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  goToSignUp(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddUser()));
  }

  goToMap(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapScreen()));
  }

  goToSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  goToServices(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ServicesList(
                  uId: 'test',
                )));
  }

  @override
  Widget build(BuildContext context) {
    Future<int> _handleLogin() async {
      int signedIn = await userAuth.signInWithEmail(
          emailController.text, passwordController.text);

      //goToMap(context);
      return signedIn;
    }

    _validateField(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      return null;
    } // _validateField

    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/ENRoute-logo.png',
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Welcome back!',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    )),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        // email entry
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validateField,
                        ),
                      ),
                      Container(
                        // password entry
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: TextFormField(
                          obscureText: !_passwordVisible,
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Color(0xff096B72),
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
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //forgot passord screen
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Forgot Your Password?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                              content: RichText(
                                text: const TextSpan(children: [
                                  TextSpan(
                                      text: 'Please email: ',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16)),
                                  TextSpan(
                                      text: 'ENRoute@gmail.com',
                                      style: TextStyle(
                                          color: Color(0xff096B72),
                                          fontSize: 16,
                                          decoration: TextDecoration.underline))
                                ]),
                              ),
                            ),
                            /*const Text(
                                        'Please email ENRoute@gmail.com.'),*/
                          );
                        },
                        child: const Text('Forgot Password?',
                            style: TextStyle(color: Color(0xff096B72))),
                      ),

                      // What is commented out below is the buttons for Google and Apple login
                      // Keep commented out until we can implement those features.

                      /*Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: null,                      
                        style: ButtonStyle(
                          backgroundColor:
                            MaterialStateProperty.all(Colors.black), 
                        ),
                        child: Row(children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Image.asset(
                            'assets/images/apple_icon.png',
                            width: 15,
                            height: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Apple",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)
                          ),
                          SizedBox(
                            width: 20,
                          ),
                        ]),
                      ),
                      ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                        ),
                        child: Row(children: <Widget>[
                          SizedBox(
                            width: 20,
                          ),
                          Image.asset(
                            'assets/images/google_logo.png',
                            width: 15,
                            height: 15,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Google",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              )
                              ),
                              SizedBox(
                            width: 20,
                          ),
                        ]),
                      ),
                    ]),
                SizedBox(
                  height: 15
                ),*/
                      Container(
                          // login button
                          height: 50,
                          width: 200,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: ElevatedButton(
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 20),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff096B72)),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  int res = await _handleLogin();
                                  if (res == 0) {
                                    goToMap(context);
                                  } else if (res == 1) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _signInAlert(context,
                                                'No user associated with that email'));
                                  } else if (res == 2) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _signInAlert(context,
                                                'Invalid password for that email'));
                                  } else if (res == 3 || res == 4) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _signInAlert(context,
                                                'Please enter a valid email'));
                                  }
                                }
                              })),
                      Row(
                        // sign up button
                        children: <Widget>[
                          const Text("Don't have an account?"),
                          TextButton(
                            child: const Text(
                              'Sign up!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xff096B72),
                              ),
                            ),
                            onPressed: () => goToSignUp(context),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }
}

Widget _signInAlert(BuildContext context, String content) {
  return AlertDialog(
    title: const Text('Sign-in Error'),
    content: Text(content),
    actions: <Widget>[
      TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close')),
    ],
  );
}

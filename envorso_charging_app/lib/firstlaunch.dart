import 'package:envorso_charging_app/speech_recognition.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class FirstLaunch extends StatefulWidget {
  const FirstLaunch({Key? key}) : super(key: key);
  @override
  _FirstLaunch createState() => _FirstLaunch();
}

class _FirstLaunch extends State<FirstLaunch> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  goToSignUp(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddUser()));
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //forgot password screen
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
                    height: 50,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: ElevatedButton(
                      child: const Text('Login'),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff096B72)),
                      ),
                      onPressed: () {
                        //print(nameController.text);
                        //print(passwordController.text);
                      },
                    )),
                Row(
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
            )));
  }
}

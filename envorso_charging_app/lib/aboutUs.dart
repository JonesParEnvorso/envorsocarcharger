import 'package:flutter/material.dart';
import 'settings.dart';

// A page that gives information about us (ENRoute) and Envorso

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  goToSettings(BuildContext context) {
    Navigator.pop(context);
    //Navigator.push(context,
    //    MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(scrollDirection: Axis.vertical, children: <Widget>[
        Row(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                child: ElevatedButton(
                    onPressed: () => goToSettings(context),
                    child: const Icon(Icons.arrow_back),
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(8)),
                        backgroundColor: MaterialStateProperty.all(
                            const Color(0xff096B72)), // Button color
                        overlayColor:
                            MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black;
                          }
                          return null; // Splash color
                        })))),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
              child: const Text(
                'Information',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'About The App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Divider(
          thickness: 5,
          endIndent: 0,
          color: Color(0xff096B72),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 10, 20, 5),
          child: const Text(
            'Welcome to ENRoute!\n\nThis app allows you to easily locate, navigate, and pay for a charge in your Electric Vehicle. We take care of managing all of your charging service subscriptions.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'About Us',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(
          thickness: 5,
          endIndent: 0,
          color: Color(0xff096B72),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 5, 20, 5),
          child: const Text(
            'We are a group of five Computer Science Students from Central Washington University. This app was created as our Senior Capstone Project, under the guidance of Bob Rapp.\n\nBob Rapp is the Principal Solutions Architect at Envorso.\n\nKirsten Boyles: UI/UX Lead\n\nRichard DeYoung: Database and User Accounts Lead.\n\nLucas Keizur: Charger Data Lead.\n\nCraig Turnbull: Map Lead.\n\nJoe Corona: Speech-To-Text Lead',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'About Envorso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(
          thickness: 5,
          endIndent: 0,
          color: Color(0xff096B72),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 5, 20, 5),
          child: const Text(
            'Envorso is a technology solutions company based in Michigan.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ]),
    ));
  }
}

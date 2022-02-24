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
      title: 'Add Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class AddAcounts extends StatefulWidget {
  const AddAcounts({Key? key}) : super(key: key);
  @override
  _AddAcounts createState() => _AddAcounts();
}

class _AddAcounts extends State<AddAcounts> {
  goToSettings(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Stack(
            //flex: 1,
            children: [
          Row(
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(5, 25, 5, 0),
                  child: ElevatedButton(
                      onPressed: () => goToSettings(context),
                      child: Icon(Icons.arrow_back),
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding: MaterialStateProperty.all(EdgeInsets.all(8)),
                          backgroundColor: MaterialStateProperty.all(
                              Color(0xff096B72)), // Button color
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                                  (states) {
                            if (states.contains(MaterialState.pressed))
                              return Colors.black; // Splash color
                          })))),
              Container(
                padding: EdgeInsets.fromLTRB(5, 25, 5, 0),
                child: Text(
                  'Services',
                ),
              ),
            ],
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(5, 85, 5, 0),
            children: [
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: true,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                        )
                      ],
                    )),
                onChanged: null,
              )),
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: false,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Color(0xffcfb406),
                        )
                      ],
                    )),
                onChanged: null,
              )),
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: true,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Color(0xffcfb406),
                        )
                      ],
                    )),
                onChanged: null,
              )),
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: true,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Color(0xffcfb406),
                        )
                      ],
                    )),
                onChanged: null,
              )),
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: false,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                        )
                      ],
                    )),
                onChanged: null,
              )),
              Card(
                  child: CheckboxListTile(
                activeColor: const Color(0xff096B72),
                dense: true,
                title: Text(
                  'Test test test',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                value: true,
                secondary: Container(
                    height: 50,
                    width: 50,
                    child: Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                        )
                      ],
                    )),
                onChanged: null,
              )),
            ],
          )
        ]));
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

// A page that gives information about us (ENRoute) and Envorso

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
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
    final screenWidth = MediaQuery.of(context).size.width;
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
                'Help',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'Icons',
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
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(children: <Widget>[
                  FloatingActionButton(
                    heroTag: 'btn1',
                    backgroundColor: const Color(0xff096B72),
                    foregroundColor: Colors.white,
                    onPressed: () {},
                    child: const Icon(Icons.center_focus_strong),
                  ),
                  SizedBox(height: 15,),
                  Text('Centers on your location in the map screen.', textAlign: TextAlign.center,)
                ]),
                
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(children: <Widget>[
                  
                  FloatingActionButton(
                    
                    heroTag: 'btn2',
                    backgroundColor: const Color(0xff096B72),
                    foregroundColor: Colors.white,
                    onPressed: () {},
                    child: const Icon(Icons.filter_alt),
                  ),
                  SizedBox(height: 5,),
                  Text('Provides you with different filtering options for chargers.', textAlign: TextAlign.center,)
                ]),
                
              ),
                        
              
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(30, 10, 20, 5),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(children: <Widget>[
                  Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50
                  ),
                  Text('Location has a Super charger.', textAlign: TextAlign.center,)
                ]),
                
              ),
              Expanded(
                child: Column(children: <Widget>[
                  Icon(
                    Icons.location_pin,
                    color: Colors.yellow,
                    size: 50
                  ),
                  Text('Location does not have a Super charger.', textAlign: TextAlign.center,)
                ]),
                
              ),
                        
              
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'Search',
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
            '\n\nOnce you click the Search Bar in the map screen, it will take you to another screen where you can input a city name.\n\nOnce you enter your destination city\'s name and click the "Search" button, a list of all chargers in this location will be displayed.\n\nRest assured that only chargers with your selected charging port(s) are displayed.\n\nIf you would like to filter this list further, select the filter button at the top of the screen and select your preferences.\n\nJust like rest of the app, charger speed is indicated by a red or yellow icon. Red means that supercharge is available, yellow means that only nonsupercharge services are available',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: const Text(
            'Need More help?',
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
          child: RichText(
            text: new TextSpan(children: [
              new TextSpan(
                  text: 'Email us at: ',
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  )),
              new TextSpan(
                text: 'ENRoute@gmail.com',
                style: new TextStyle(
                  color: Color(0xff096B72),
                  fontSize: 16,
                  decoration: TextDecoration.underline
                ),
                recognizer: new TapGestureRecognizer()..onTap = () {}
              ,
              )
            ]),
          ),
        ),
      ]),
    ));
  }
}

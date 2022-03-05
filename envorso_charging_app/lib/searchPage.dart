//import 'dart:html';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings.dart';
import 'mapScreen.dart';
import 'chargeStation.dart';
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
      home: const SearchPage(
        whichFocus: 2,
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.whichFocus}) : super(key: key);

  // 0: focus searchBar
  // 1: focus mic
  // >= 2: navigatated from somewhere else other than mapScreen
  final int whichFocus;
  @override
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> {
  final searchText = TextEditingController();

  List<Map<String, dynamic>> chargers = [];

  Chargers chargeList = Chargers();

  List<listTilesLocations> tileList = [];

  bool isLoading = false;
  late FocusNode searchBarFocus;
  late FocusNode micButtonFocus;
  late bool isMicPressed;

// fills the list with the result from the database
  _fillChargerList() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uId;
    if (auth.currentUser == null) {
      print("No user!?!? How did you even get here?");
      return;
    } else {
      uId = auth.currentUser!.uid;
    }
    await chargeList.activateAccount(uId);
    String city = searchText.text;
    chargers = await chargeList.findCity(city);
    chargers = chargeList.maskPlugs(chargers);
    //chargers2 = await chargeList.pullServices(46.999883, -120.544755);
  }

  //const _searchPage({Key? key}) : super(key: key);
  @override
  goToSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  goToMap(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MapScreen()));
  }

  _generateList() async {
    setState(() {
      isLoading = true;
    });
    isLoading = true;
    tileList = [];
    chargers = [];
    await _fillChargerList();
    await _generateTile();
    setState(() {
      isLoading = false;
    });
  }

  _generateTile() async {
    String address;
    bool superc;
    String plugs;
    for (var station in chargers) {
      plugs = "";
      address =
          station['address'] + " " + station['city'] + ", " + station['state'];
      if (station['DC fast'] > 0) {
        superc = true;
      } else {
        superc = false;
      }

      for (var plug in station['plug']) {
        plugs += plug;
        plugs += "\n";
      }
      tileList.add(listTilesLocations(
          id: 123,
          superc: superc,
          title: station['network'],
          address: address,
          lvl1: station['level 1'],
          lvl2: station['level 2'],
          dcFast: station['DC fast'],
          plugs: plugs));
    }
  }

  @override
  void initState() {
    super.initState();

    searchBarFocus = FocusNode();
    micButtonFocus = FocusNode();
    isMicPressed = false;
    if (widget.whichFocus == 0) {
      searchBarFocus.requestFocus();
    } else if (widget.whichFocus == 1) {
      micButtonFocus.requestFocus();
      isMicPressed = true;
    }
  }

  @override
  void dispose() {
    searchText.dispose();
    searchBarFocus.dispose();
    micButtonFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Column(
          children: <Widget>[
            /*Container(
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
            )),*/
            Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 0, 0),
                child: Row(children: [
                  Container(
                      child: ElevatedButton(
                    onPressed: () => goToMap(context),
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
                        } // Splash color
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
                      padding: const EdgeInsets.all(1),
                      width: 250,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: searchText,
                        focusNode: searchBarFocus,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                        ),
                      )),
                  Container(
                      child: ElevatedButton(
                    onPressed: () {
                      //speech.MyApp;
                      speech.main();
                    },
                    focusNode: micButtonFocus,
                    child: Icon(isMicPressed ? Icons.mic_none : Icons.mic),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(8)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color(0xff732015)), // Button color
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black;
                        }
                        return null; // Splash color
                      }),
                    ),
                  )),
                ])),
            Container(
              height: 70,
              width: 300,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: ElevatedButton(
                  onPressed: () {
                    _generateList();
                  },
                  child: const Text(
                    'Search',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff096B72)),
                  )),
            ),
            Container(
              height: 2,
              width: 340,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: const Color(0xff096B72),
            ),
            Container(
                height: 500,
                child:
                    isLoading // starts off as true, changes to false once list has been loaded in
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff096B72),
                            ),
                          )
                        : Scrollbar(
                            isAlwaysShown: true,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                //physics: NeverScrollableScrollPhysics(),
                                itemCount: tileList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Card(
                                      child: ListTile(
                                          leading: Icon(Icons.location_pin,
                                              color: tileList[index].superc
                                                  ? Colors.red
                                                  : Colors.yellow),
                                          title: Text(tileList[index].title,
                                              textAlign: TextAlign.left),
                                          subtitle: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                tileList[index].address,
                                                textAlign: TextAlign.left,
                                              ),
                                              Text(
                                                  "DC Fast: " +
                                                      tileList[index]
                                                          .dcFast
                                                          .toString() +
                                                      " | Level 2: " +
                                                      tileList[index]
                                                          .lvl2
                                                          .toString() +
                                                      " | Level 1: " +
                                                      tileList[index]
                                                          .lvl1
                                                          .toString(),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 15,
                                                      color: Colors.black))
                                            ],
                                          ),
                                          trailing: Text(
                                            tileList[index].plugs,
                                            textAlign: TextAlign.right,
                                          ))
                                      /*
                                      child: ListTile(
                                    leading: Icon(Icons.location_pin,
                                        color: tileList[index].superc
                                            ? Colors.red
                                            : Colors.yellow),
                                    title: Text(tileList[index].title),
                                    subtitle: Text(tileList[index].address),
                                  )*/
                                      );
                                }),
                          )),
          ],
        )));
  }
}

class listTilesLocations {
  int id;
  bool superc;
  String title;
  String address;
  int lvl1;
  int lvl2;
  int dcFast;
  String plugs;

  listTilesLocations(
      {required this.id,
      required this.superc,
      required this.title,
      required this.address,
      required this.lvl1,
      required this.lvl2,
      required this.dcFast,
      required this.plugs});
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'newUserEmail.dart';
import 'enRouteAccountSettings.dart';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings.dart';
import 'mapScreen.dart';
import 'chargeStation.dart';
import 'main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saved Locations Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class SavedLocations extends StatefulWidget {
  const SavedLocations({Key? key}) : super(key: key);
  @override
  _SavedLocations createState() => _SavedLocations();
}

class _SavedLocations extends State<SavedLocations> {
  bool cost = true;
  bool free = true;
  bool dcFast = true;
  bool lvl1 = true;
  bool lvl2 = true;

  bool firstLoad = true;
  String userID = "";

  final searchText = TextEditingController();

  List<Map<String, dynamic>> chargers = [];
  List<dynamic> chargersID = [];

  Chargers chargeList = Chargers();

  List<listTilesLocations> tileList = [];

  bool isLoading = false;
  late FocusNode searchBarFocus;
  late FocusNode micButtonFocus;
  late bool isMicPressed;

  bool visible = false;

  void showFilterOptions() {
    setState(() {
      visible = !visible;
    });
  }

  _remove(String id) async {
    chargersID.remove(id);
    chargers.removeWhere((element) => element['id'] == id);

    String uId = userID;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set({'saved': chargersID}, SetOptions(merge: true)).then((value) {});
    setState(() {});
  }

  _fillChargerList() async {
    print("hello");
    print("1");
    List<Map<String, dynamic>> temp = [];
    chargers = [];
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uId;
    if (auth.currentUser == null) {
      print("No user!?!? How did you even get here?");
      return;
    } else {
      uId = auth.currentUser!.uid;
    }
    userID = uId;
    print("2");
    var querryL =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    var a = querryL.get('saved');
    chargersID = a;
    print("3");
    var querryList =
        await FirebaseFirestore.instance.collection('stations').get();
    for (var docs in querryList.docs) {
      temp.add(docs.data());
    }
    print("4");
    for (var doc in temp) {
      if (chargersID.contains(doc['id'])) {
        chargers.add(doc);
      }
    }
  }

// fills the list with the result from the database
  _fillChargerList1() async {
    chargers = [];
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
    city = city.toLowerCase();
    chargers = await chargeList.findCity("yakima");
    chargers = chargeList.maskPlugs(chargers);
    //chargers2 = await chargeList.pullServices(46.999883, -120.544755);
  }

  goToMap(BuildContext context) {
    Navigator.pop(context);
    //Navigator.push(
    //    context, MaterialPageRoute(builder: (context) => const MapScreen()));
  }

  _generateList() async {
    setState(() {
      isLoading = true;
    });
    await _fillChargerList();
    await _generateTile();
    setState(() {
      isLoading = false;
    });
  }

  bool _isFiltered(Map<String, dynamic> charge) {
    bool filtered = true;
    bool s = false;
    bool c = false;
    if (free && charge['price'] == "Free") {
      c = true;
    }
    if (cost && charge['price'] != "Free") {
      c = true;
    }
    if (dcFast && charge['DC fast'] > 0) {
      s = true;
    }
    if (lvl2 && charge['level 2'] > 0) {
      s = true;
    }
    if (lvl1 && charge['level 1'] > 0) {
      s = true;
    }
    if (s && c) {
      filtered = false;
    }

    return filtered;
  }

  _generateTile() async {
    tileList = [];
    chargersID = [];
    String address;
    bool superc;
    String plugs;
    for (var station in chargers) {
      chargersID.add(station['id']);
      if (!_isFiltered(station)) {
        plugs = "";
        address = station['address'] +
            " " +
            station['city'] +
            ", " +
            station['state'];
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
            plugs: plugs,
            dbID: station['id']));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      firstLoad = false;
      _generateList();
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Column(
            children: <Widget>[
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
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text(
                          "My Saved Chargers",
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff096B72),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ))
                  ])),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                height: 2,
                width: 340,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: const Color(0xff096B72),
              ),
              Container(
                  height: 550,
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                        child: ListTile(
                                            leading: Icon(Icons.location_pin,
                                                color: tileList[index].superc
                                                    ? Colors.red
                                                    : Colors.yellow),
                                            title: Text(tileList[index].title,
                                                textAlign: TextAlign.left),
                                            subtitle: Positioned(
                                                left: 20,
                                                child: Column(
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
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            fontStyle: FontStyle
                                                                .italic,
                                                            fontSize: 15,
                                                            color:
                                                                Colors.black)),
                                                    TextButton.icon(
                                                      style: ButtonStyle(
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          padding: MaterialStateProperty
                                                              .all(const EdgeInsets
                                                                      .fromLTRB(
                                                                  0, 0, 0, 0)),
                                                          alignment: Alignment
                                                              .centerLeft),
                                                      icon: const Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color:
                                                            Color(0xff096B72),
                                                      ),
                                                      label: const Text(
                                                          'Remove',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                      onPressed: () {
                                                        _remove(tileList[index]
                                                            .dbID);
                                                        _generateTile();
                                                      },
                                                    )
                                                  ],
                                                )),
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
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                height: 2,
                width: 340,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: const Color(0xff096B72),
              )
            ],
          ),
          Positioned(
            top: 30,
            right: 30,
            child: FloatingActionButton(
              backgroundColor: const Color(0xff096B72),
              foregroundColor: Colors.white,
              onPressed: () {
                showFilterOptions();
              },
              heroTag: 'back',
              child: const Icon(Icons.filter_alt),
            ),
          ),
          Positioned(
            top: 100,
            right: 10,
            child: Visibility(
                visible: visible,
                child: Container(
                  //padding: EdgeInsets.all(0),
                  height: 200,
                  //height: 85,
                  width: 115,
                  decoration: const BoxDecoration(
                      color: Color(0xff096B72),
                      borderRadius: BorderRadius.all(Radius.circular(20))),

                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
                      shrinkWrap: true,
                      children: [
                        TextButton.icon(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              alignment: Alignment.centerLeft),
                          icon: const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                          ),
                          label: const Text('By Price',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        ),
                        SizedBox(
                            height: 35,
                            child: TextButton(
                                onPressed: () {
                                  free = !free;
                                  _generateTile();
                                  setState(() {});
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text("Free",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      checkColor: Colors.white,
                                      value: free,
                                      onChanged: (value) {
                                        free = value!;
                                        _generateTile();
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ))),
                        SizedBox(
                            height: 35,
                            child: TextButton(
                                onPressed: () {
                                  cost = !cost;
                                  _generateTile();
                                  setState(() {});
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text("Costs",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      checkColor: Colors.white,
                                      value: cost,
                                      onChanged: (value) {
                                        setState(() {
                                          cost = value!;
                                          _generateTile();
                                        });
                                      },
                                    )
                                  ],
                                ))),
                        TextButton.icon(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              alignment: Alignment.centerLeft),
                          icon: const Icon(
                            Icons.speed,
                            color: Colors.white,
                          ),
                          label: const Text('By Speed',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {},
                        ),
                        //Column(children: <Widget>[
                        SizedBox(
                            height: 35,
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    dcFast = !dcFast;
                                    _generateTile();
                                  });
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text("DC fast",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      checkColor: Colors.white,
                                      value: dcFast,
                                      onChanged: (value) {
                                        dcFast = value!;
                                        _generateTile();
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ))),
                        SizedBox(
                            height: 35,
                            child: TextButton(
                                onPressed: () {
                                  lvl2 = !lvl2;
                                  _generateTile();
                                  setState(() {});
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text("Level 2",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      checkColor: Colors.white,
                                      value: lvl2,
                                      onChanged: (value) {
                                        lvl2 = value!;
                                        _generateTile();
                                        setState(() {});
                                      },
                                    )
                                  ],
                                ))),
                        SizedBox(
                            height: 35,
                            child: TextButton(
                                onPressed: () {
                                  lvl1 = !lvl1;
                                  _generateTile();
                                  setState(() {});
                                },
                                child: Row(
                                  children: <Widget>[
                                    Text("Level 1",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      checkColor: Colors.white,
                                      value: lvl1,
                                      onChanged: (value) {
                                        lvl1 = value!;
                                        _generateTile();
                                        setState(() {});
                                      },
                                    )
                                  ],
                                )))
                      ]),
                )),
          )
        ]));
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
  String dbID;

  listTilesLocations(
      {required this.id,
      required this.superc,
      required this.title,
      required this.address,
      required this.lvl1,
      required this.lvl2,
      required this.dcFast,
      required this.plugs,
      required this.dbID});
}


// add_circle_outline

/*
FloatingActionButton(
                onPressed: () {},
                child: Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    color: Colors.black),
                backgroundColor: Colors.white,
              ),
*/
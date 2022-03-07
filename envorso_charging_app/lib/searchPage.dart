//import 'dart:html';
import 'dart:ffi';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'settings.dart';
import 'mapScreen.dart';
import 'chargeStation.dart';
import 'main.dart';
import 'speech_recognition.dart' as speech;

class MapReturnValues {
  List<Map<String, dynamic>> chargers = [];
  int index = 0;
  MapReturnValues(this.chargers, this.index);
}

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
  bool cost = true;
  bool free = true;
  bool dcFast = true;
  bool lvl1 = true;
  bool lvl2 = true;
  List<dynamic> chargersID = [];
  String userID = "";

  final searchText = TextEditingController();

  List<Map<String, dynamic>> chargers = [];

  Chargers chargeList = Chargers();

  List<listTilesLocations> tileList = [];

  bool isLoading = false;
  late FocusNode searchBarFocus;
  late FocusNode micButtonFocus;
  late bool isMicPressed;

  late stt.SpeechToText _speech;
  late bool _isListening;
  String _text = 'Press button and speak';
  double _confidence = 1.0;

  bool visible = false;

  void showFilterOptions() {
    setState(() {
      visible = !visible;
    });
  }

// fills the list with the result from the database
  _fillChargerList() async {
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
    chargers = await chargeList.findCity(city);
    chargers = chargeList.maskPlugs(chargers);
    //chargers2 = await chargeList.pullServices(46.999883, -120.544755);
  }

  //const _searchPage({Key? key}) : super(key: key);
  @override
  goToSettings(BuildContext context) {
    Navigator.pop(context);
    //Navigator.push(context,
    //    MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  goToMap(BuildContext context) {
    Navigator.pop(context);
    //Navigator.push(
    //    context, MaterialPageRoute(builder: (context) => const MapScreen()));
  }

  _remove(String id) async {
    chargersID.remove(id);

    String uId = userID;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set({'saved': chargersID}, SetOptions(merge: true)).then((value) {});
    setState(() {});
  }

  _add(String id) async {
    chargersID.add(id);

    String uId = userID;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set({'saved': chargersID}, SetOptions(merge: true)).then((value) {});
    setState(() {});
  }

  _pullAccount() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uId;
    if (auth.currentUser == null) {
      print("No user!?!? How did you even get here?");
      return;
    } else {
      uId = auth.currentUser!.uid;
    }
    userID = uId;
    var querryL =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();
    var a = querryL.get('saved');
    chargersID = a;
  }

  _generateList() async {
    setState(() {
      isLoading = true;
    });
    isLoading = true;
    await _fillChargerList();
    await _generateTile();
    setState(() {
      isLoading = false;
    });
    setState(() {});
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
    String address;
    bool superc;
    String plugs;
    for (var station in chargers) {
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
            dbID: station['id'],
            contains: (chargersID.contains(station['id']))));
      }
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
      _isListening = false;
      isMicPressed = false;
    } else if (widget.whichFocus == 1) {
      micButtonFocus.requestFocus();
      isMicPressed = true;
      _isListening = true;
    }
  }

  @override
  void dispose() {
    searchText.dispose();
    searchBarFocus.dispose();
    micButtonFocus.dispose();
    super.dispose();
  }

  bool firstLoad = true;
  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      firstLoad = false;
      _pullAccount();
    }
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Column(
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

//<<<<<<< HEAD
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
                        // handle listen in here. Be sure to set the boolean values accordingly once the _listen is finished
                        setState(() {
                          isMicPressed = !isMicPressed;
                          _isListening = !_isListening;
                        });
                        print('pressed');
                        //_listen,
                      },
                      child: Icon(_isListening ? Icons.mic_none : Icons.mic),
                      // speech.main();
                      // setState(() {
                      //   isMicPressed = !isMicPressed;
                      // });
                      //},
                      focusNode: micButtonFocus,
                      //child: Icon(isMicPressed ? Icons.mic_none : Icons.mic),
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

                        //Container(
                        // padding: const EdgeInsets.all(1),
                        // width: 250,
                        // child: TextField(
                        //   keyboardType: TextInputType.text,
                        //   controller: searchText,
                        //   focusNode: searchBarFocus,
                        //   decoration: InputDecoration(
                        //     prefixIcon: const Icon(Icons.search),
                        //     hintText: "Search",
                        //     hintStyle: const TextStyle(color: Colors.grey),
                        //     border: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(25.0)),
                      ),
                    )),
                  ])),
              //   Container(
              //       child: ElevatedButton(
              //     onPressed: () {
              //       //speech.MyApp;
              //       speech.main();
              //       setState(() {
              //         isMicPressed = !isMicPressed;
              //       });
              //     },
              //     focusNode: micButtonFocus,
              //     child: Icon(isMicPressed ? Icons.mic_none : Icons.mic),
              //     style: ButtonStyle(
              //       shape: MaterialStateProperty.all(const CircleBorder()),
              //       padding:
              //           MaterialStateProperty.all(const EdgeInsets.all(8)),
              //       backgroundColor: MaterialStateProperty.all(
              //           const Color(0xff732015)), // Button color
              //       overlayColor:
              //           MaterialStateProperty.resolveWith<Color?>((states) {
              //         if (states.contains(MaterialState.pressed)) {
              //           return Colors.black;
              //         }
              //         return null; // Splash color
              //       }),
              //     ),
              //   )),
              // ])),
              Container(
                height: 70,
                width: 200,
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                        child: ListTile(
                                            onTap: () => {
                                                  Navigator.pop(
                                                      context,
                                                      MapReturnValues(
                                                          chargers, index))
                                                },
                                            leading: Icon(Icons.location_pin,
                                                color: tileList[index].superc
                                                    ? Colors.red
                                                    : Colors.yellow,
                                                size: 50),
                                            title: Text(tileList[index].title,
                                                textAlign: TextAlign.center),
                                            subtitle: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  tileList[index].address,
                                                  textAlign: TextAlign.center,
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
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        fontSize: 15,
                                                        color: Colors.black)),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Visibility(
                                                          visible:
                                                              tileList[index]
                                                                  .contains,
                                                          child:
                                                              TextButton.icon(
                                                            style: ButtonStyle(
                                                                visualDensity:
                                                                    VisualDensity
                                                                        .compact,
                                                                padding: MaterialStateProperty.all(
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0)),
                                                                alignment: Alignment
                                                                    .centerLeft),
                                                            icon: const Icon(
                                                              Icons
                                                                  .remove_circle_outline,
                                                              color: Color(
                                                                  0xff096B72),
                                                            ),
                                                            label: const Text(
                                                                'Unsave',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            onPressed: () {
                                                              setState(() {
                                                                _remove(tileList[
                                                                        index]
                                                                    .dbID);
                                                                _generateTile();
                                                              });
                                                            },
                                                          )),
                                                      Visibility(
                                                          visible:
                                                              !tileList[index]
                                                                  .contains,
                                                          child:
                                                              TextButton.icon(
                                                            style: ButtonStyle(
                                                                visualDensity:
                                                                    VisualDensity
                                                                        .compact,
                                                                padding: MaterialStateProperty.all(
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        0,
                                                                        0,
                                                                        0,
                                                                        0)),
                                                                alignment: Alignment
                                                                    .centerLeft),
                                                            icon: const Icon(
                                                              Icons
                                                                  .add_circle_outline,
                                                              color: Color(
                                                                  0xff096B72),
                                                            ),
                                                            label: const Text(
                                                                'Save',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                            onPressed: () {
                                                              setState(() {
                                                                _add(tileList[
                                                                        index]
                                                                    .dbID);
                                                                _generateTile();
                                                              });
                                                            },
                                                          ))
                                                    ]),
                                              ],
                                            ),
                                            trailing: SizedBox(
                                              width: 90,
                                              child: Text(tileList[index].plugs,
                                                  textAlign: TextAlign.right),
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
          ),
          Positioned(
            top: 100,
            left: 30,
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
            top: 170,
            left: 10,
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
                      controller: ScrollController(),
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
                                    Text("Free      ",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
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
                                    Text("Fares    ",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
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
                                    Text("DC Fast",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
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
                                    Text("Level 2 ",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
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
                                    Text("Level 1 ",
                                        style: TextStyle(color: Colors.white)),
                                    Checkbox(
                                      visualDensity: VisualDensity.compact,
                                      activeColor: Colors.white,
                                      checkColor: Colors.black,
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
  bool contains;

  listTilesLocations(
      {required this.id,
      required this.superc,
      required this.title,
      required this.address,
      required this.lvl1,
      required this.lvl2,
      required this.dcFast,
      required this.plugs,
      required this.dbID,
      required this.contains});
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  // final Map<String, HighlightedWord> _highlights = {
  //   'Washington': HighlightedWord(
  //     onTap: () => print('Washington'),
  //     textStyle: const TextStyle(
  //       color: Colors.blue,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  // };

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press button and speak';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          // child: TextHighlight(
          //   text: _text,
          //   words: _highlights,
          //   textStyle: const TextStyle(
          //     fontSize: 32.0,
          //     color: Colors.black,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  printSomething() {
    _listen();
  }
}

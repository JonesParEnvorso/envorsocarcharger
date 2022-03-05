import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'chargeStation.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' as maplauncher;
import 'package:flutter_svg/flutter_svg.dart';
import 'searchPage.dart';
import 'speech_recognition.dart' as speech;
//import 'package:google_place/google_place.dart' as googleplace;
import 'savedLocations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'settings.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

//import 'newUser.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

// speech recognition
//String get speechRecognition => 'speech_recognition.dart';

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
      home: const MapScreen(),
    );
  }
}

// Mapscreen widget
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

// Mapscreen state
class _MapScreenState extends State<MapScreen> {
  goToSavedLocations() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SavedLocations()));
  }

  goToSettings(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  // Location data
  late LocationData currentLocation;
  //late LocationData _currentPosition;
  Location location = Location();
  LatLng curLatLng = const LatLng(0, 0);
  // Charger data
  Chargers chargers = Chargers();
  List<Map<String, dynamic>> chargerData = [];
  List<Marker> markers = [];
  // Google Maps data
  late GoogleMapController _googleMapController;
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(39.983235, -98.966782), // Lat/Long target.
    zoom: 2, // Max zoom level is normally 21.
  );
  // Marker icons
  late BitmapDescriptor redMarkerIcon;
  late BitmapDescriptor yellowMarkerIcon;
  // Polyline data
  Set<Polyline> polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  int polyLineIdCounter = 1;

  // Display card data
  bool isCardDisplayed = false;
  int highlightedMarkerInd = -1;

  //GoogleMapPolyline googleMapPolyline = new GoogleMapPolyline();
  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  // Called upon state initialization
  @override
  void initState() {
    //showChargersAtLocation();
    super.initState();
  }

  bool visible = false;
  bool applyVisible = false;
  bool changeMade = false;
  List<bool> c = [true, true];
  List<bool> s = [true, true, true];
  var plugs = [];

  Future _activateFilterPlugs() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String uId;
    if (auth.currentUser == null) {
      print("No user!?!? How did you even get here?");
      return;
    } else {
      uId = auth.currentUser!.uid;
    }
    while (await chargers.activateAccount(uId) == 1) {}
    setState(() {
      plugs = chargers.carPlugs;
    });
    print(plugs);
  }

  void showFilterOptions() {
    setState(() {
      visible = !visible;
      if (!visible) {
        applyVisible = false;
      }
      if (changeMade && visible) {
        applyVisible = true;
      }
    });
  }

  void ApplyVisible() {
    changeMade = true;
    applyVisible = true;
  }

  void ApplyFilters() {
    setState(() {
      /*changeMade = false;
      applyVisible = false;
      c = [free, cost];
      s = [dcFast, lvl2, lvl1];*/
      // Hide every expensive charger
      for (int i = 0; i < chargerData.length; i++) {
        if ((!free && chargerData[i]['price'].compareTo("FREE") == 0) ||
            (!cost && chargerData[i]['price'].compareTo("FREE") != 0) ||
            !((dcFast && chargerData[i]['DC fast'] > 0) ||
                (lvl1 && chargerData[i]['level 1'] > 0) ||
                (lvl2 && chargerData[i]['level 2'] > 0))) {
          print("applyin");

          markers[i] = markers[i].copyWith(
            visibleParam: false,
          );
        } else if (!markers[i].visible) {
          markers[i] = markers[i].copyWith(visibleParam: true);
        }
      }
      //_fillChargerList(currentLocation.latitude!, currentLocation.longitude!);
    });
  }

  bool cost = true;
  bool free = true;
  bool dcFast = true;
  bool lvl1 = true;
  bool lvl2 = true;

  @override
  // Generate map view
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    //getStation();
    return Scaffold(
        // Google Map component values
        body: Stack(children: [
      // Google Map
      Positioned.fill(
          child: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) =>
            {_googleMapController = controller, showChargersAtLocation()},
        markers: Set.of(markers), // Displays markers
        polylines: polylines,
      )),
      // Info card
      if (highlightedMarkerInd >= 0)
        Positioned(
          left: 0,
          top: 0,
          child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                Row(children: [
                  Container(
                      // Green background
                      width: screenWidth / 1.18,
                      height: 200,
                      padding: EdgeInsets.only(top: 20),
                      decoration: const BoxDecoration(
                        color: Color(0xff096B72),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Container(
                          // White card
                          width: screenWidth / 1.18,
                          height: 205,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                          ),
                          child: Column(children: [
                            Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        // Charger name
                                        (chargerData[highlightedMarkerInd]
                                            ['name']),
                                        style: new TextStyle(
                                            color: const Color(0xff096B72),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20)),
                                    Text("Address",
                                        style: new TextStyle(
                                            color: const Color(0xff096B72),
                                            fontWeight: FontWeight.bold)),
                                    Text("" + //
                                        chargerData[highlightedMarkerInd]
                                            ['address'] +
                                        ", " +
                                        chargerData[highlightedMarkerInd]
                                            ['city'] +
                                        " " +
                                        chargerData[highlightedMarkerInd]
                                            ['state']),
                                    Text(
                                        ("DC fast " +
                                            chargerData[highlightedMarkerInd]
                                                    ['DC fast']
                                                .toString()),
                                        style: new TextStyle(
                                            color: const Color(0xff096B72),
                                            fontWeight: FontWeight.bold)),
                                    // Network
                                    Text("Network",
                                        style: new TextStyle(
                                            color: const Color(0xff096B72),
                                            fontWeight: FontWeight.bold)),
                                    Text(chargerData[highlightedMarkerInd]
                                        ['network']),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FloatingActionButton(
                                    backgroundColor: const Color(0xff096B72),
                                    foregroundColor: Colors.white,
                                    onPressed: () =>
                                        launchMap(highlightedMarkerInd),
                                    child: const Icon(Icons.near_me),
                                    heroTag: 'center',
                                  ),
                                ])
                          ])))
                ])
              ])),
        ),
      // Recenter button
      Positioned(
          right: 30,
          bottom: 150,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff096B72),
            foregroundColor: Colors.white,
            onPressed: () => getLocation(_googleMapController),
            child: const Icon(Icons.center_focus_strong),
            heroTag: 'center',
          )),
      // Debug refresh button: call this function when x miles away from previous

      Positioned(
          right: 30,
          bottom: 230,
          child: FloatingActionButton(
            backgroundColor: const Color(0xff096B72),
            foregroundColor: Colors.white,
            onPressed: () => {
              fillChargerListOnScreen(
                  screenWidth, screenHeight, _googleMapController)
            },
            child: const Icon(Icons.refresh),
            //heroTag: 'center',
          )),
      // Back button
      Positioned(
          height: 28,
          width: 95,
          bottom: 422,
          left: 40,
          child: Visibility(
            visible: applyVisible,
            child: ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.green[700]) // Color(0xff096B72)
                  ),
              onPressed: () {
                setState(() {
                  ApplyFilters();
                });
              },
              //heroTag: 'back',
              child: const Text("Apply"),
            ),
          )),
      Positioned(
        bottom: 220,
        left: 30,
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
                              ApplyFilters();
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
                                    ApplyFilters();
                                  },
                                )
                              ],
                            ))),
                    SizedBox(
                        height: 35,
                        child: TextButton(
                            onPressed: () {
                              cost = !cost;
                              ApplyFilters();
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
                                      ApplyFilters();
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
                                ApplyFilters();
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
                                    ApplyFilters();
                                  },
                                )
                              ],
                            ))),
                    SizedBox(
                        height: 35,
                        child: TextButton(
                            onPressed: () {
                              lvl2 = !lvl2;
                              ApplyFilters();
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
                                    ApplyFilters();
                                  },
                                )
                              ],
                            ))),
                    SizedBox(
                        height: 35,
                        child: TextButton(
                            onPressed: () {
                              lvl1 = !lvl1;
                              ApplyFilters();
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
                                    ApplyFilters();
                                  },
                                )
                              ],
                            )))
                    //])
                  ]),
            )),
      ),
      Positioned(
        bottom: 150,
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
      // THIS IS ALL SEARCH BAR STUFF PLEASE DON'T TOUCH D:
      // If you do touch, please contact Kirsten, its sensitive :)
      Positioned(
          left: 0,
          bottom: 0,
          child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: screenWidth / 1.18,
                    height: 105,
                    decoration: const BoxDecoration(
                      color: Color(0xff096B72),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(children: [
                      Row(children: [
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextButton.icon(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              )),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              alignment: Alignment.centerLeft,
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            icon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            label: const Text('Search',
                                style: TextStyle(color: Colors.grey)),
                            onPressed: () {
                              Navigator.of(context).push(_createRoute(0));
                              //speech.main();
                            },
                          ),
                        ),
                        Container(
                            child: ElevatedButton(
                          onPressed: () {
                            //speech.main();
                            // go to searchpage and focus the mic button
                            Navigator.of(context).push(_createRoute(1));
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const speech )
                          },
                          child: const Icon(Icons.mic),
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(8)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xff732015)), // Button color
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                    (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.black;
                              }
                              return null; // Splash color
                            }),
                          ),
                        )),
                      ]),
                      Row(
                        children: [
                          const SizedBox(
                            width: 30,
                          ),
                          Container(
                              padding: const EdgeInsets.all(2),
                              width: 280,
                              decoration: const BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                ),
                              ))),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            label: (const Text('My locations',
                                style: TextStyle(color: Colors.white))),
                            onPressed: () =>
                                Navigator.of(context).push(_saveLocations()),
                          ),
                          Container(
                              padding: const EdgeInsets.all(2),
                              width: 1,
                              height: 30,
                              decoration: const BoxDecoration(
                                  border: Border(
                                left: BorderSide(
                                  color: Colors.white,
                                ),
                              ))),
                          TextButton.icon(
                            icon:
                                const Icon(Icons.settings, color: Colors.white),
                            label: (const Text('Settings',
                                style: TextStyle(color: Colors.white))),
                            onPressed: () => goToSettings(context),
                          ),
                          const SizedBox(
                            width: 33,
                          )
                        ],
                      )
                    ]),
                  ),
                ],
              )))
    ]));
  }

  // Opens the map launcher (not yet binded)
  openMapsSheet(context) async {
    try {
      final coords =
          maplauncher.Coords(37.759392, -122.5107336); // Set charger coords
      const title = "Charger"; // Set charger title here
      final availableMaps = await maplauncher.MapLauncher.installedMaps;

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                          coords: coords,
                          title: title,
                        ),
                        title: Text(map.mapName),
                        leading: SvgPicture.asset(
                          map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // Set the location before the map is rendered (WIP)
  void initializeLocation() async {
    //_currentPosition = await location.getLocation();
  }

  // Updates charger list to include chargers in center of the screen.
  void fillChargerListOnScreen(
      screenWidth, screenHeight, _googleMapController) async {
    ScreenCoordinate screenCoordinate = ScreenCoordinate(
        x: (screenWidth / 2).round(), y: (screenHeight / 2).round());
    LatLng middlePoint = await _googleMapController.getLatLng(screenCoordinate);
    _fillChargerList(middlePoint.latitude, middlePoint.longitude);
  }

  // Recenters the map on the user's location
  Future<void> getLocation(GoogleMapController controller) async {
    // Wait for controller if not valid

    // Wait for location
    currentLocation = await location.getLocation();
    curLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    // Move map camera
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      zoom: 17.0,
    )));
  }

  // Launches a pin in Google Maps (Provide more later)
  void launchMap(int markerInd) async {
    final availableMaps = await maplauncher.MapLauncher.installedMaps;
/*
    await availableMaps.first.showMarker(
      coords: maplauncher.Coords(
          chargerData[markerInd]['lat'], chargerData[markerInd]['lon']),
      title: (chargerData[markerInd]['network'] + "Charger location"),
      description: "Level 2 charger, Greenlots",
    );
*/
    if (await maplauncher.MapLauncher.isMapAvailable(
            maplauncher.MapType.google) !=
        null) {
      await maplauncher.MapLauncher.showMarker(
          mapType: maplauncher.MapType.google,
          coords: maplauncher.Coords(
              chargerData[markerInd]['lat'], chargerData[markerInd]['lon']),
          title: (chargerData[markerInd]['network'] + " Charger"),
          description: "Level 2 charger, Greenlots");
    }
  }

  void showChargersAtLocation() async {
    await _activateFilterPlugs();
    await getLocation(_googleMapController);
    await _fillChargerList(
        currentLocation.latitude!, currentLocation.longitude!);
  }

  // Populate charger data list.
  // TO DO: use unique keys for recalculating
  _fillChargerList(double lat, double lon) async {
    // Pull data
    print("ok");
    var newChargerData = await chargers.pullChargers(lat, lon);
    print(newChargerData.length);
    for (int i = 0; i < newChargerData.length; i++) {
      bool chargerAlreadyAdded = false;
      int j = 0;
      while (!chargerAlreadyAdded && j < chargerData.length) {
        if ((chargerData[j]['address']
                .compareTo(newChargerData[i]['address']) ==
            0)) {
          chargerAlreadyAdded = true;
        }
        j++;
      }
      if (!chargerAlreadyAdded) {
        chargerData.add(newChargerData[i]);
        print("yep");
      }
    }
    print(chargerData.length);
    //chargerData = chargers.filterChargers(chargerData, s, c);
    //chargerData = chargers.maskPlugs(chargerData);
    markers = [];
    // Print the lat and long of every charger
    for (int i = 0; i < chargerData.length; i++) {
      print("City: ${chargerData[i]['city']}");
      print("lat: ${chargerData[i]['lat']}");
      print("lon: ${chargerData[i]['lon']}");

      LatLng pos = LatLng(chargerData[i]['lat'], chargerData[i]['lon']);
      setState(() {
        markers.add(Marker(
            markerId: (MarkerId(markers.length.toString())),
            position: pos,
            icon: (chargerData[i]['DC fast'] > 0)
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueYellow),
            onTap: () async {
              selectMarker(i);
            }));
      });
    }
  }

  Route _createRoute(int focus) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SearchPage(
        whichFocus: focus,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Rebuilds the directions polyline object using parse json directions.
  void setPolyline(List<PointLatLng> points) {
    polylines = Set<Polyline>();
    polyLineIdCounter = 0;
    final String polylineIdVal = 'polyline_$polyLineIdCounter';
    polyLineIdCounter++;
    setState(() {
      polylines.add(Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 2,
          color: Colors.blue,
          points: points
              .map(
                (point) => LatLng(point.latitude, point.longitude),
              )
              .toList()));
    });
  }

  // Gets and parses directions from Google Directions
  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=AIzaSyCufwN5aCc05dezlsn3WYLsRJTLtfohLpk';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline_decoded': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    //print(json);
    return results;
  }

  // Sets which charger will be displayed on the info card
  void selectMarker(int ind) async {
    setState(() {
      highlightedMarkerInd = ind;
    });
    // Get directions from directions API
    String origin = currentLocation.latitude.toString() +
        "," +
        currentLocation.longitude.toString();
    String destination = chargerData[ind]['lat'].toString() +
        "," +
        chargerData[ind]['lon'].toString();
    print(origin + " " + destination);
    var directions = await getDirections(origin, destination);
    // Redefine polyline using json data

    setPolyline(directions['polyline_decoded']);
  }

  Route _saveLocations() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SavedLocations(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

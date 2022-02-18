import 'package:flutter/material.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'newUser.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' as maplauncher;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

// Leaflet / OpenMap implementation
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    var markers = <Marker>[];
    markers = [
      Marker(
          point: LatLng(46.999843, -120.539261),
          builder: (ctx) => IconButton(
              icon: Icon(Icons.location_pin),
              color: Colors.red,
              onPressed: () => launchMap())),
    ];

    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
        child: FlutterMap(
            options: MapOptions(
                interactiveFlags: InteractiveFlag.all &
                    ~InteractiveFlag.rotate, // Disable rotation
                center: LatLng(46.999843, -120.539261),
                zoom: 17),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                maxZoom: 20.0,
                maxNativeZoom: 19.0,
              ),
              MarkerLayerOptions(markers: markers)
            ]),
      ),
      Positioned(
          left: 0,
          bottom: 10,
          child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                      width: screenWidth / 1.18,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xff096B72),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Row(children: [
                        SizedBox(
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
                                  EdgeInsets.fromLTRB(10, 0, 0, 0)),
                              alignment: Alignment.centerLeft,
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            icon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            label: Text('Search',
                                style: TextStyle(color: Colors.grey)),
                            onPressed: () {
                              Navigator.of(context).push(_createRoute());
                            },
                          ),
                        ),
                        Container(
                            child: ElevatedButton(
                          onPressed: () {},
                          child: Icon(Icons.mic),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(CircleBorder()),
                            padding:
                                MaterialStateProperty.all(EdgeInsets.all(8)),
                            backgroundColor: MaterialStateProperty.all(
                                Color(0xff732015)), // <-- Button color
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                    (states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.black; // <-- Splash color
                            }),
                          ),
                        )),
                      ])),
                ],
              )))
    ]));
  }

  // Launches a pin in Google Maps (Provide more later)
  void launchMap() async {
    final availableMaps = await maplauncher.MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: maplauncher.Coords(46.999843, -120.539261),
      title: "Charger location",
      description: "Level 2 charger, Greenlots",
    );

    if (await maplauncher.MapLauncher.isMapAvailable(
            maplauncher.MapType.google) !=
        null) {
      await maplauncher.MapLauncher.showMarker(
          mapType: maplauncher.MapType.google,
          coords: maplauncher.Coords(46.999843, -120.539261),
          title: "Charger Location",
          description: "Level 2 charger, Greenlots");
    }
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const searchPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class searchPage extends StatelessWidget {
  const searchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(left: 10),
            width: 270,
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ))
      ],
    )));
  }
}

/*
// Google Maps display.
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // State objects
  late LocationData _currentPosition;
  late GoogleMapController _googleMapController;
  Location location = Location();
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(46.999843, -120.539261), // Lat/Long target.
    zoom: 11.5, // Max zoom level is normally 21.
  );

  // Called upon state initialization
  void initState() {
    super.initState();
    //initializeLocation();
    //getLocation(_googleMapController);
  }

  // List of markers on map
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

//Experimenting with database calls. Does not currently work
/*
  void getStation() async {
    final CollectionReference station =
        FirebaseFirestore.instance.collection('stations');
    station.where('city', isEqualTo: "Ellensburg").get().then((QuerySnapshot) {
      for (var result in QuerySnapshot.docs) {
        _addMarker(LatLng(result.get('lat'), result.get('lat')));
      }
    });
  }
*/

  @override
  // Generate map view
  Widget build(BuildContext context) {
    //getStation();
    return Scaffold(
      // Google Map component values
      body: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        // Displays set of markers on map.
        markers: Set.of(_markers.values),
        // Long press to add marker (example)
        onLongPress: _addMarker,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          // Recenter button
          Positioned(
              right: 30,
              bottom: 10,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                onPressed: () => getLocation(_googleMapController),
                child: const Icon(Icons.center_focus_strong),
                heroTag: 'center',
              )),
          // Back button
          Positioned(
            left: 20,
            top: 50,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              heroTag: 'back',
              child: const Icon(Icons.arrow_back),
            ),
          )
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        // Animate to starting location on press.
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),*/
    );
  }

  // Opens the map launcher (not yet binded)
  openMapsSheet(context) async {
    try {
      final coords = Coords(37.759392, -122.5107336); // Set charger coords
      final title = "Charger"; // Set charger title here
      final availableMaps = await MapLauncher.installedMaps;

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

  // Adds a marker to the map display.
  // Currently stores as a map of <MarkerId, Marker>.
  // Probably needs to be made public before calling from firebase.
  void _addMarker(LatLng pos) {
    MarkerId _newMarkerId = MarkerId(_markers.length.toString());
    setState(() {
      _markers[_newMarkerId] = Marker(markerId: _newMarkerId, position: pos);
    });
  }

  // Set the location before the map is rendered (WIP)
  void initializeLocation() async {
    _currentPosition = await location.getLocation();
  }

  // Recenters the map on the user's location
  void getLocation(GoogleMapController controller) async {
    // Wait for location
    LocationData currentLocation;
    currentLocation = await location.getLocation();
    // Move map camera
    _googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      zoom: 17.0,
    )));
  }

  // Launches a URL in app.
  // Probably not going to be used for navigation, but may be useful base for
  // connecting to charger services.
  /*
  void _launchMapsUrl(String originPlaceId, String destinationPlaceId) async {
    String mapOptions = [
      'origin=$originPlaceId',
      'origin_place_id=$originPlaceId',
      'destination=$destinationPlaceId',
      'destination_place_id=$destinationPlaceId',
      'dir_action=navigate'
    ].join('&');

    final url = 'https://www.google.com/maps/dir/api=1&$mapOptions';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
*/

}
*/
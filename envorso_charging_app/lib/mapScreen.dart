import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'newUser.dart';

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

// Google Maps display.
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Stores starting map coordinates
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(46.999883, -120.544755), // Lat/Long target.
    zoom: 11.5, // Max zoom level is normally 21.
  );

  late GoogleMapController _googleMapController;
  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  @override
  // Dispose map controller resources.
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Google Map component values
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) => _googleMapController = controller,
        // Displays set of markers on map.
        markers: Set.of(_markers.values),
        // Long press to add marker (example)
        onLongPress: _addMarker,
      ),
      // Recenters on user location (hardcoded here)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              right: 30,
              bottom: 10,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                // Animate to starting location on press.
                onPressed: () => _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialCameraPosition),
                ),
                child: const Icon(Icons.center_focus_strong),
                heroTag: 'center',
              )),
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

  // Adds a marker to the map display.
  // Currently stores as a map of <MarkerId, Marker>.
  // Probably needs to be made public before calling from firebase.
  void _addMarker(LatLng pos) {
    MarkerId _newMarkerId = MarkerId(_markers.length.toString());
    setState(() {
      _markers[_newMarkerId] = Marker(markerId: _newMarkerId, position: pos);
    });
  }
}

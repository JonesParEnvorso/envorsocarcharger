import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

//This class will pull and store the collection of chagers
class Chargers {
  //the max number of chargers being pulled at any given time
  int maxSize = 15;
  //the max range of the chargers being querried
  int range = 3;

  var chargerList;

  //Constructor
  Chargers();

  //Pull down n < maxSize chargers into a list
  void pullCharger(LatLng latlong) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    chargerList = await FirebaseFirestore.instance
        .collection('stations')
        .limit(maxSize)
        .where('city', isEqualTo: "Ellensburg")
        .get();
  }

  //Change the search range of chargers
  void changeRange(int miles) {
    range = miles;
  }

  //order the list of chargers by price
  void orderPrice() {}

  //order the list of chargers by Charger type
  void orderCharger() {}

  //order the list of chargers by Distance from user
  void orderDistance() {}

  //order the list of chargers by membership status
  void orderMembership(List<String> mems) {}

  //order the list of chargers by charging Speed
  void orderSpeed() {}
}

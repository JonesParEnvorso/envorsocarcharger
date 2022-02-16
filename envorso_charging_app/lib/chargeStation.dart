import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

class CharTest {
  CharTest() {
    run();
  }
  void run() async {
    print("start");
    //ellensburg is 46.999883, -120.544755
    var stations = Chargers();
    await stations.pullChargers(46.999883, -120.544755);
    stations.printChargers();
  }
}

//This class will pull and store the collection of chagers
class Chargers {
  //the max number of chargers being pulled at any given time
  int maxSize = 15;
  //the max range of the chargers being querried
  double range = 0.042478;

  List<Map<String, dynamic>> chargers = [];

  //Constructor
  Chargers();

  //Pull down n < maxSize chargers into a list
  pullChargers(double lat, double lon) async {
    var querryList = await FirebaseFirestore.instance
        .collection('stations')
        .limit(maxSize)
        .where('city', isEqualTo: "Ellensburg")
        //.where('lon', isLessThan: (lon + range), isGreaterThan: (lon - range))
        .get();
    for (var docs in querryList.docs) {
      chargers.add(docs.data());
    }
  }

  //Change the search range of chargers
  void changeRange(int miles) async {
    range = miles / 69.00;
  }

  void printChargers() async {
    print(chargers.length);
    for (int i = 0; i < chargers.length; i++) {
      print(chargers.elementAt(i)['name']);
    }
  }

  //order the list of chargers by price
  void orderPrice() async {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by Charger type
  void orderCharger() {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by Distance from user
  void orderDistance() {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by membership status
  void orderMembership(List<String> mems) {}

  //order the list of chargers by charging Speed
  void orderSpeed() {
    List<Map<String, dynamic>> temp = [];
  }
}

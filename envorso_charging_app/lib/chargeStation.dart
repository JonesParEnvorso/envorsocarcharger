import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import "dart:math";

//This class will pull and store the collection of chagers
class Chargers {
  //the max number of chargers being pulled at any given time
  int maxSize = 10;
  //the max range of the chargers being querried
  double range = 0.042478;
  //the stored list of vehicle chargers
  List<Map<String, dynamic>> chargers = [];
  //the Array of memberships
  List<dynamic> memberships = [];
  //the array of car plugs
  List<dynamic> carPlug = [];
  //the map of user info
  Map<String, dynamic> userInfo = {};

  //Constructor
  Chargers() {}

  //Pull down n < maxSize chargers into a list
  Future<List<Map<String, dynamic>>> pullChargers(
      double lat, double lon) async {
    var querryList = await FirebaseFirestore.instance
        .collection('stations')
        .limit(maxSize)
        //.where('city', isEqualTo: "Ellensburg")
        //.where('lon', isLessThan: (lon + range), isGreaterThan: (lon - range))
        .get();

    chargers = [];
    for (var docs in querryList.docs) {
      chargers.add(docs.data());
    }

    orderDistance(lat, lon);

    return chargers;
  }

  //Pulls user data and stores it in the Class feilds.
  Future<List<Map<String, dynamic>>> activateAccount(String key) async {
    DocumentSnapshot<Map<String, dynamic>> userPlug = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(key)
        .collection("chargerType")
        .doc('chargers')
        .get();
    DocumentSnapshot<Map<String, dynamic>> userMem = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(key)
        .collection("services")
        .doc('services')
        .get();

    carPlug = userPlug['chargerType'];
    memberships = userMem['services'];

    return chargers;
  }

  //set the array of car plugs
  void setCarPlug(List<String> plugs) {
    carPlug = plugs;
  }

  //set the array of memberships
  void setMemberships(List<String> mems) {
    memberships = mems;
  }

  //set the search range of chargers
  void setRange(int miles) {
    range = miles / 69.00;
  }

  //set the max return size of chargers
  void setMaxSize(int size) {
    maxSize = size;
  }

  //Remove from the List all plug types not owned by the user
  List<Map<String, dynamic>> maskPlugs() {
    for (var n in chargers) {
      if (!((n['plug'].contains("CHADEMO") && carPlug.contains("CHAdeMO")) ||
          (n['plug'].contains("J1772") && carPlug.contains("J1772")) ||
          (n['plug'].contains("J1772COMBO") &&
              carPlug.contains("SAE Combo CCS")))) {
        chargers.remove(n);
      }
    }
    return chargers;
  }

  //Place all plug types not owned by the user at the back of the list
  List<Map<String, dynamic>> orderPlugs() {
    List<Map<String, dynamic>> temp = [];
    for (var n in chargers) {
      if (!((n['plug'].contains("CHADEMO") && carPlug.contains("CHAdeMO")) ||
          (n['plug'].contains("J1772") && carPlug.contains("J1772")) ||
          (n['plug'].contains("J1772COMBO") &&
              carPlug.contains("SAE Combo CCS")))) {
        temp.add(n);
        chargers.remove(n);
      }
    }
    chargers.addAll(temp);
    return chargers;
  }

  //Remove from the List all Membership types not owned by the user
  List<Map<String, dynamic>> maskServices() {
    for (var n in chargers) {
      if (!(memberships.contains(n['network']) ||
          memberships.contains("Electrical Vehicle Charging Station"))) {
        chargers.remove(n);
      }
    }
    return chargers;
  }

  //Place all Membership types not owned by the user at the back of the list
  List<Map<String, dynamic>> orderServices() {
    List<Map<String, dynamic>> temp = [];
    for (var n in chargers) {
      if (!(memberships.contains(n['network']) ||
          memberships.contains("Electrical Vehicle Charging Station"))) {
        temp.add(n);
        chargers.remove(n);
      }
    }
    chargers.addAll(temp);
    return chargers;
  }

//Remove from the List all charge speeds not specified in the parameter array
  List<Map<String, dynamic>> maskSpeed(List<String> levels) {
    if (!levels.contains("level 1")) {
      for (var n in chargers) {
        if (!(n["level 2"] > 0 || n["DC fast"] > 0)) {
          chargers.remove(n);
        }
      }
    }
    if (!levels.contains("level 2")) {
      for (var n in chargers) {
        if (!(n["level 1"] > 0 || n["DC fast"] > 0)) {
          chargers.remove(n);
        }
      }
    }
    if (!levels.contains("DC fast")) {
      for (var n in chargers) {
        if (!(n["level 2"] > 0 || n["level 1"] > 0)) {
          chargers.remove(n);
        }
      }
    }
    return chargers;
  }

  //order the list of chargers by charging Speed
  List<Map<String, dynamic>> orderSpeed() {
    List<Map<String, dynamic>> lev1 = [];
    List<Map<String, dynamic>> lev2 = [];
    List<Map<String, dynamic>> dcFast = [];

    for (var n in chargers) {
      if (n['DC fast'] > 0) {
        dcFast.add(n);
        //chargers.remove(n);
      } else if (n['level 2'] > 0) {
        lev2.add(n);
        //chargers.remove(n);
      } else if (n['level 1'] > 0) {
        lev1.add(n);
        //chargers.remove(n);
      }
    }
    chargers = [];
    chargers.addAll(dcFast);
    chargers.addAll(lev2);
    chargers.addAll(lev1);
    return chargers;
  }

  //order the list of chargers by price
  void orderPrice() async {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by Distance from user
  List<Map<String, dynamic>> orderDistance(double lat, double lon) {
    List<Map<String, dynamic>> temp = [];
    num distanceA = 0;
    num distanceB = 0;
    bool isSorted = false;

    while (!isSorted) {
      isSorted = true;

      for (int i = 1; i < chargers.length; i++) {
        distanceA =
            pow(chargers[i - 1]['lat'], 2) + pow(chargers[i - 1]['lon'], 2);
        distanceB = pow(chargers[i]['lat'], 2) + pow(chargers[i]['lon'], 2);
        if (distanceB < distanceA) {
          chargers.insert(i - 1, chargers.elementAt(i));
          chargers.removeAt(i + 1);
          isSorted = false;
        }
      }
    }
    return chargers;
  }

  //Debuging tool to print charging station names
  void printChargers() {
    print(chargers.length);
    for (int i = 0; i < chargers.length; i++) {
      print(chargers.elementAt(i)['name']);
    }
  }
}

class Debugger {
  Debugger() {
    run();
  }
  void run() async {
    var charger = Chargers();
    //charger.activateAccount("0fKNcfWsxhrawuATfGUd");
    await charger.pullChargers(46.9965, 120.5478);
    await charger.activateAccount("0fKNcfWsxhrawuATfGUd");
    charger.printChargers();
    charger.orderSpeed();
    charger.printChargers();
  }
}

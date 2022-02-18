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
  int maxSize = 10;
  //the max range of the chargers being querried
  double range = 0.042478;
  //the stored list of vehicle chargers
  List<Map<String, dynamic>> chargers = [];
  //the Array of memberships
  List<String> memberships = [];
  //the array of car plugs
  List<String> carPlug = [];
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
        .where('city', isEqualTo: "Ellensburg")
        //.where('lon', isLessThan: (lon + range), isGreaterThan: (lon - range))
        .get();

    chargers = [];
    for (var docs in querryList.docs) {
      chargers.add(docs.data());
    }

    return chargers;
  }

  //Pulls user data and stores it in the Class feilds.
  void activateAccount(String key) async {
    DocumentSnapshot<Map<String, dynamic>> user =
        await FirebaseFirestore.instance.collection('users').doc(key).get();

    carPlug = user['chargerType']['chargers'];
    memberships = user['services']['services'];
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

  void maskSpeed(List<String> levels) {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by charging Speed
  void orderSpeed() {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by price
  void orderPrice() async {
    List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by Distance from user
  void orderDistance() {
    List<Map<String, dynamic>> temp = [];
  }

  //Debuging tool to print charging station names
  void printChargers() {
    print(chargers.length);
    for (int i = 0; i < chargers.length; i++) {
      print(chargers.elementAt(i)['name']);
    }
  }
}

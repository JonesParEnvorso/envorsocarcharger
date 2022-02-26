import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:math";

//This class will pull and store the collection of chagers
class Chargers {
  //the max number of chargers being pulled at any given time
  int minSize = 2;
  //the max range of the chargers being querried
  int range = 4;
  //the stored list of vehicle chargers
  List<Map<String, dynamic>> chargers = [];
  //the Array of memberships
  List<dynamic> memberships = [];
  //the array of car plugs
  List<dynamic> carPlugs = [];
  //the map of user info
  Map<String, dynamic> userInfo = {};

  //Constructor
  Chargers();

  //Pull down chargers into a list
  Future<List<Map<String, dynamic>>> pullChargers(
      double lat, double lon) async {
    chargers = [];
    List<List<int>> geoList = getGeoSet((geoHash(lat, lon)), range);
    //print(geo);
    //List<int> geo = [83867952, 83867950];
    bool foundChargers = false;
    while (!foundChargers) {
      chargers = [];
      for (var geoHash in geoList) {
        var querryList = await FirebaseFirestore.instance
            .collection('stations')
            .where('geoHash', whereIn: geoHash)
            .get();
        for (var docs in querryList.docs) {
          chargers.add(docs.data());
        }
      }
      if (range > 6) {
        return chargers;
      } else if (chargers.length >= minSize) {
        foundChargers = true;
      } else {
        range++;
      }
    }
    print(range);
    range = 4;
    orderDistance(lat, lon);
    return chargers;
  }

  Future<List<Map<String, dynamic>>> findCity(String city) async {
    chargers = [];
    var querryList = await FirebaseFirestore.instance
        .collection('stations')
        .where('city', isEqualTo: city)
        .get();
    for (var docs in querryList.docs) {
      chargers.add(docs.data());
    }
    return chargers;
  }

  Future<List<String>> pullServices(double lat, double lon) async {
    var local = await pullChargers(lat, lon);
    List<String> networks = [];

    for (var plug in local) {
      if (!networks.contains(plug['network'])) {
        networks.add(plug['network']);
      }
    }

    return networks;
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

    carPlugs = userPlug['chargerType'];
    memberships = userMem['services'];

    return chargers;
  }

  //set the array of car plugs
  void setCarPlug(List<String> plugs) {
    carPlugs = plugs;
  }

  //set the array of memberships
  void setMemberships(List<String> mems) {
    memberships = mems;
  }

  //set the search range of chargers
  void setRange(int miles) {
    range = miles;
  }

  //set the max return size of chargers
  void setMinSize(int size) {
    minSize = size;
  }

  //Remove from the List all plug types not owned by the user
  List<Map<String, dynamic>> maskPlugs() {
    for (var n in chargers) {
      if (!((n['plug'].contains("CHADEMO") && carPlugs.contains("CHAdeMO")) ||
          (n['plug'].contains("J1772") && carPlugs.contains("J1772")) ||
          (n['plug'].contains("J1772COMBO") &&
              carPlugs.contains("SAE Combo CCS")))) {
        chargers.remove(n);
      }
    }
    return chargers;
  }

  //Place all plug types not owned by the user at the back of the list
  List<Map<String, dynamic>> orderPlugs() {
    List<Map<String, dynamic>> temp = [];
    for (var n in chargers) {
      if (!((n['plug'].contains("CHADEMO") && carPlugs.contains("CHAdeMO")) ||
          (n['plug'].contains("J1772") && carPlugs.contains("J1772")) ||
          (n['plug'].contains("J1772COMBO") &&
              carPlugs.contains("SAE Combo CCS")))) {
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
    //List<Map<String, dynamic>> temp = [];
  }

  //order the list of chargers by Distance from user
  List<Map<String, dynamic>> orderDistance(double lat, double lon) {
    //List<Map<String, dynamic>> temp = [];
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

  /*
  //identify the geoHash for the given lat/lon
  */
  int geoHash(double lat, double lon) {
    int lattitude = (lat * 100).truncate() * 4500;
    int longitude = ((lon * 100) / 2).truncate();

    return lattitude + longitude;
  }

  /*
  //determines the surrounding geoHashes and returns it as a set
  */
  List<List<int>> getGeoSet(int geoHash, int range) {
    int high = range;
    int low = range * (-1);
    List<List<int>> geoSet = [];
    List<int> temp = [];
    int count = 0;
    print("start Geo Set");

    for (int i = low; i <= high; i++) {
      for (int k = low; k <= high; k++) {
        if (count == 10) {
          geoSet.add(temp);
          temp = [];
          count = 0;
        }
        temp.add(geoHash + (i * 4500) + (k));
        count++;
      }
    }
    geoSet.add(temp);
    print("End Geo Set");
    return geoSet;
  }

  //Debuging tool to print charging station names
  void printChargers() {
    print(chargers.length);
    for (int i = 0; i < chargers.length; i++) {
      print(chargers.elementAt(i));
    }
  }
}

class Debugger {
  Debugger() {
    run();
  }

  void run() async {
    var charger = Chargers();
    //await charger.pullChargers(46.999883, -120.544755); //46.999883, -120.544755
    //await charger.activateAccount("0fKNcfWsxhrawuATfGUd");
    //charger.printChargers();
    print(await charger.pullServices(46.999883, -120.544755));
    print("done");
    //addGeoHash();
  }

  //This function applies a geoHash to each charging station
  // DO NOT CALL THIS FUNCTION
  void addGeoHash() async {
    print("start");
    var charger = Chargers();

    var querryList =
        await FirebaseFirestore.instance.collection('stations').get();

    List<Map<String, dynamic>> chargers = [];
    for (var docs in querryList.docs) {
      chargers.add(docs.data());
      chargers.last['id'] = docs.id;
    }

    for (var entries in chargers) {
      FirebaseFirestore.instance.collection('stations').doc(entries['id']).set(
          {'geoHash': charger.geoHash(entries['lat'], entries['lon'])},
          SetOptions(merge: true)).then((value) {});
    }
    print("complete");
  }
}

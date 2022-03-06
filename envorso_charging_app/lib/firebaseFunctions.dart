import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'userAuth.dart';

// class for all firebase functions
class FirebaseFunctions {
  FirebaseFunctions();

  // global firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // global auth object
  UserAuth userAuth = UserAuth();

  // gets user's id
  String getUId() {
    String? uId = auth.currentUser?.uid;
    if (uId == null) {
      print("How did you get here?");
      return '';
    }
    return uId;
  }

  // create new user account
  Future<String?> createAccount(String email, String password) async {
    RegExp reg = RegExp('[a-z0-9]+@[a-z]+\.[a-z]{2,3}');
    if (!reg.hasMatch(email)) {
      return 'invalid email';
    }
    String? uId = await userAuth.registerWithEmail(email, password);

    if (uId == null) {
      // null check for safety
      return '';
    }
    return uId;
  } // createAccount

  // create new user document
  // email and password are passed to newUser.dart from newUserEmail.dart
  // account creation occurs all at once
  createUser(
      String uId,
      String email,
      String password,
      String username,
      String phoneNumber,
      String street,
      String city,
      String zip,
      String state,
      String name,
      String creditCard,
      String expiry,
      String cvv,
      List<String> chargers) async {
    CollectionReference users = firestore.collection('users');

    String firstName;
    String lastName;
    if (name == '') {
      firstName = '';
      lastName = '';
    } else if (!name.contains(" ")) {
      firstName = name;
      lastName = "";
    } else {
      firstName = name.substring(0, name.indexOf(" "));
      lastName = name.substring(name.indexOf(" ") + 1);
    }

    await users
        .doc(uId)
        .set({
          "email": email,
          "password": password,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'countryCode':
              '+1', // default to +1 since we are only focusing on USA
          'address': {
            // address is a map
            "city": city,
            "street": street,
            "state": state,
            "zip": zip,
          },
          "creditCard": {
            // credit card is also a map
            "num": creditCard,
            "exp": expiry,
            "cvv": cvv,
          },
          "username": username,
          "saved": []
        })
        .then((value) => users
            .doc(uId)
            .collection('chargerType')
            .doc('chargers')
            .set({'chargerType': chargers}))
        .catchError((Object error) => Future.error(Exception("$error")));
  } // createUser

  // update account
  updateAccount(
      String uId,
      String username,
      String phoneNumber,
      String street,
      String city,
      String zip,
      String state,
      String name,
      String creditCard,
      String expiry,
      String cvv,
      List<String> chargers) async {
    DocumentReference curUser = firestore.collection('users').doc(uId);
    DocumentSnapshot<Map<String, dynamic>> data =
        await firestore.collection('users').doc(uId).get();

    Map<String, dynamic>? map = data.data();
    if (map == null) {
      print("No map");
      return;
    }

    String firstName;
    String lastName;
    if (name == '') {
      firstName = '';
      lastName = '';
    } else if (!name.contains(" ")) {
      firstName = name;
      lastName = "";
    } else {
      firstName = name.substring(0, name.indexOf(" "));
      lastName = name.substring(name.indexOf(" ") + 1);
    }

    // check to make sure no data is overwritten
    if (firstName == '') {
      firstName = map['firstName'];
    }
    if (lastName == '') {
      lastName = map['lastName'];
    }
    if (phoneNumber == '') {
      phoneNumber = map['phoneNumber'];
    }
    if (username == '') {
      username = map['username'];
    }
    if (street == '') {
      street = map['address']['street'];
    }
    if (city == '') {
      city = map['address']['city'];
    }
    if (zip == '') {
      zip = map['address']['zip'];
    }
    if (state == '') {
      state = map['address']['state'];
    }
    if (creditCard == '') {
      creditCard = map['creditCard']['num'];
    }
    if (expiry == '') {
      expiry = map['creditCard']['exp'];
    }
    if (cvv == '') {
      cvv = map['creditCard']['cvv'];
    }

    // properly update chargers

    await curUser
        .update({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'countryCode':
              '+1', // default to +1 since we are only focusing on USA
          'address': {
            // address is a map
            "city": city,
            "street": street,
            "state": state,
            "zip": zip,
          },
          "creditCard": {
            // credit card is also a map
            "num": creditCard,
            "exp": expiry,
            "cvv": cvv,
          },
          "username": username,
        })
        .then((value) => curUser
            .collection('chargerType')
            .doc('chargers')
            .set({'chargerType': chargers}))
        .catchError((Object error) => Future.error(Exception("$error")));
  }

  // add services to a user document
  addServices(String uId, List<String> services) async {
    firestore
        .collection('users')
        .doc(uId)
        .collection('services')
        .doc('services')
        .set({'services': services}).catchError(
            (Object error) => Future.error(Exception("$error")));
  } // addServices

  // get users current chargers
  Future<List<String>> getChargers(String uId) async {
    List<String> res = [];

    DocumentSnapshot<Map<String, dynamic>> data = await firestore
        .collection('users')
        .doc(uId)
        .collection('chargerType')
        .doc('chargers')
        .get();

    Map<String, dynamic>? map = data.data();
    if (map == null) {
      print('no map');
      return res;
    }

    List<dynamic> charge = map['chargerType'];

    for (int i = 0; i < charge.length; i++) {
      res.add(charge[i]);
    }

    return res;
  } // getChargers

  // get all user PID
  Future<Map<String, dynamic>> getPID(String uId) async {
    DocumentSnapshot<Map<String, dynamic>> data =
        await firestore.collection('users').doc(uId).get();

    Map<String, dynamic>? map = data.data();

    if (map == null) {
      return {};
    }

    return map;
  } // getPID

  // get all unique services
  Future<List<Map<String, String>>> getServices(String uId) async {
    QuerySnapshot<Map<String, dynamic>> data =
        await firestore.collection('stations').orderBy('network').get();

    List<Map<String, dynamic>> list =
        data.docs.map((doc) => doc.data()).toList();

    List<Map<String, String>> uniqueServices = [];
    List<String> uniqueNames = [];

    String userZip = '';
    await firestore
        .collection('users')
        .doc(uId)
        .get()
        .then((DocumentSnapshot docSnap) {
      userZip = docSnap.get(FieldPath(const ['address', 'zip']));
    });

    DocumentSnapshot<Map<String, dynamic>> myServ = await firestore
        .collection('users')
        .doc(uId)
        .collection('services')
        .doc('services')
        .get();

    Map<String, dynamic>? data2 = myServ.data();
    if (data2 == null) {
      return uniqueServices;
    }

    // find user's services
    List<dynamic> userServices = data2.values.toList()[0];

    // add local first?
    for (int i = 0; i < list.length; i++) {
      String tempZip = list[i]['zip'].toString();
      Map<String, String> map = {};

      // check if zip matches with user's zip
      // need to grab: zip, network, name, price
      // map contains: zip, price, displayName, databaseName, inUser

      if (tempZip == userZip && !(uniqueNames.contains(list[i]['network']))) {
        //map['network'] = list[i]['network'];
        map['zip'] = userZip;
        if (list[i]['network'] == 'Non-Networked') {
          String name = list[i]['name'];
          name += ' (' + list[i]['city'] + ')';
          map['displayName'] = name;
          map['databaseName'] = list[i]['name'];

          // inUser used to determine if service is present in user's document
          if (userServices.contains(list[i]['name'])) {
            map['inUser'] = 'true';
          } else {
            map['inUser'] = 'false';
          }
        } else {
          map['displayName'] = list[i]['network'];
          map['databaseName'] = list[i]['network'];

          if (userServices.contains(list[i]['network'])) {
            map['inUser'] = 'true';
          } else {
            map['inUser'] = 'false';
          }
        }
        map['price'] = list[i]['price'].toString();

        uniqueServices.add(map);

        if (list[i]['network'] != 'Non-Networked') {
          uniqueNames.add(list[i]['network']);
        } else {
          list.removeAt(i);
        }
      }
    }

    for (int i = 0; i < list.length; i++) {
      Map<String, String> map = {};

      // non-unique network
      if (uniqueNames.contains(list[i]['network'])) {
        continue;
      }
      if (list[i]['network'] != 'Non-Networked') {
        uniqueNames.add(list[i]['network']);
      }

      //map['network'] = list[i]['network'];
      map['zip'] = list[i]['zip'].toString();

      if (list[i]['network'] == 'Non-Networked') {
        String name = list[i]['name'];
        name += ' (' + list[i]['city'] + ')';
        map['displayName'] = name;
        map['databaseName'] = list[i]['name'];

        if (userServices.contains(list[i]['name'])) {
          map['inUser'] = 'true';
        } else {
          map['inUser'] = 'false';
        }
      } else {
        map['displayName'] = list[i]['network'];
        map['databaseName'] = list[i]['network'];

        if (userServices.contains(list[i]['network'])) {
          map['inUser'] = 'true';
        } else {
          map['inUser'] = 'false';
        }
      }

      map['price'] = list[i]['price'].toString();

      uniqueServices.add(map);
    }

    return uniqueServices;
  }
}

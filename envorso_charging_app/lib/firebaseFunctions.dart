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

  // global auth object
  UserAuth userAuth = UserAuth();

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
  }

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
  }

  // get users current chargers
  Future<List<String>> getChargers(String uId) async {
    DocumentReference chargers = firestore
        .collection('users')
        .doc(uId)
        .collection('chargerType')
        .doc('chargers');

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

    //print(map['chargerType']);

    List<dynamic> charge = map['chargerType'];

    for (int i = 0; i < charge.length; i++) {
      res.add(charge[i]);
    }

    return res;
  }
}

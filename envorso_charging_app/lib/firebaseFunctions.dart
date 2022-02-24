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
    if (!email.contains('@')) {
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
    // use uId as doc id
    /*String? uId = await userAuth.registerWithEmail(email, password);

    if (uId == '' || uId == null) {
      return '';
    }*/

    CollectionReference users = firestore.collection('users');

    String firstName;
    String lastName;
    if (name == '') {
      firstName = '';
      lastName = '';
    } else if (name.contains(" ")) {
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

  // add credit card info

  // add chargers
}

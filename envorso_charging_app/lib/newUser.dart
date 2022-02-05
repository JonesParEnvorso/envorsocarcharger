import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'mapScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add user',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AddUserPage(),
    );
  }
}

// create new user from user input
class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);
  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUserPage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // fields for firebase
    /*final Map<String, String> address;
    final Map<String, String> creditCard;
    final String email;
    final String name;
    final chargerType = <String>[];
    final subscriptions = <String>[];*/

    final newAddress = TextEditingController();
    final newCard = TextEditingController();
    final newEmail = TextEditingController();
    final newName = TextEditingController();
    final newChargerType = TextEditingController();
    final newSubscriptions = TextEditingController();

    goToMaps(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapScreen()));
    }

    @override
    void initState() {
      super.initState();
      //_controller = TextEditingController();
    }

    @override
    void dispose() {
      //_controller.dispose();
      newName.dispose();
      newEmail.dispose();
      newAddress.dispose();
      newCard.dispose();
      newChargerType.dispose();
      newSubscriptions.dispose();
      super.dispose();
    }

    Future<void> addUser() {
      String name = newName.text;
      String email = newEmail.text;
      String address = newAddress.text; // needs to be map
      String chargerType = newChargerType.text; // needs to be array
      String creditCard = newCard.text; // needs to be map
      String subscriptions = newSubscriptions.text; // needs to be array

      newName.clear();
      newCard.clear();
      newChargerType.clear();
      newSubscriptions.clear();
      newEmail.clear();
      newAddress.clear();

      return users
          .add({
            'name': name,
            'address': address,
            "chargerType": chargerType,
            "creditCard": creditCard,
            "subscriptions": subscriptions,
            "email": email,
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Add user"),
      ),
      body: ListView(
        children: <Widget>[
          // text entries
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newName,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Name'),
            ),
          ),
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newEmail,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Email'),
            ),
          ),
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newAddress,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Address'),
            ),
          ),
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newCard,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Credit Card'),
            ),
          ),
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newChargerType,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Charger Type'),
            ),
          ),
          Container(
            width: 280,
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: newSubscriptions,
              autocorrect: false,
              decoration: InputDecoration(hintText: 'Subscriptions'),
            ),
          ),
          TextButton(
              onPressed: addUser, child: Text("Add User")), // submit button
          TextButton(
              onPressed: () => goToMaps(context),
              child: Text("Maps Screen")), // navigation button
        ],
      ),
    );
  }
}

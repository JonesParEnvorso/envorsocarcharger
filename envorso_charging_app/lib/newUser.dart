import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
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
      title: 'Sign up',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AddUser(),
      /*home: Scaffold(
        appBar: AppBar(title: const Text('Sign up')),
        body: const AddUserPage(),
      ),*/
    );
  }
}

// create new user from user input
class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);
  @override
  _AddUser createState() => _AddUser();
}

class _AddUser extends State<AddUser> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  // address consists of: city, state, street, zip
  final newCity = TextEditingController();
  final newStreet = TextEditingController();
  final newState = TextEditingController();
  final newZip = TextEditingController();
  final newCountry = TextEditingController();
  // card consists of: number, expiration, and cvv
  final newCard = TextEditingController();
  final newExpirMon = TextEditingController();
  final newExpirYr = TextEditingController();
  final newCvv = TextEditingController();

  final newName = TextEditingController();
  final newEmail = TextEditingController();
  final newPhone = TextEditingController();

  // chargerType and Subscriptions still need to be fully updated
  // charger type will be array
  final newChargerType = TextEditingController();
  // subscriptions will be array
  final newSubscriptions = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // device dimensions. makes fields consistent across all devices
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final leftEdge = MediaQuery.of(context).padding.left;
    final rightEdge = MediaQuery.of(context).padding.right;

    // padding around the text entry boxes
    const inputPadding = EdgeInsets.all(10.0);

    goToMaps(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MapScreen()));
    }

    @override
    void initState() {
      super.initState();
    }

    @override
    void dispose() {
      //_controller.dispose();
      newName.dispose();
      newEmail.dispose();
      newPhone.dispose();
      newCity.dispose();
      newStreet.dispose();
      newState.dispose();
      newZip.dispose();
      newCountry.dispose();
      newCard.dispose();
      newExpirMon.dispose();
      newExpirYr.dispose();
      newCvv.dispose();
      newChargerType.dispose();
      newSubscriptions.dispose();

      super.dispose();
    }

    _addUser() async {
      //String name = newName.text; // split name into first and last
      String firstName;
      String lastName;
      if (!newName.text.contains(" ")) {
        firstName = newName.text;
        lastName = "";
      } else {
        firstName = newName.text.substring(0, newName.text.indexOf(" "));
        lastName = newName.text.substring(newName.text.indexOf(" ") + 1);
      }
      String email = newEmail.text;
      String phoneNumber = newPhone.text;
      String city = newCity.text;
      String street = newStreet.text;
      String state = newState.text;
      String zip = newZip.text;
      String creditCard = newCard.text;
      String expir = newExpirMon.text + "/" + newExpirYr.text;
      String cvv = newCvv.text;
      String chargerType = newChargerType.text; // needs to be array
      String subscriptions = newSubscriptions.text; // needs to be array

      // clear text entries
      newName.clear();
      newPhone.clear();
      newCard.clear();
      newChargerType.clear();
      newSubscriptions.clear();
      newEmail.clear();
      newState.clear();
      newStreet.clear();
      newCity.clear();
      newZip.clear();
      newCountry.clear();
      newExpirMon.clear();
      newExpirYr.clear();
      newCvv.clear();

      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      DocumentReference ref;
      await users
          .add({
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
            //"chargerType": chargerType,
            "creditCard": {
              // credit card is also a map
              "num": creditCard,
              "exp": expir,
              "cvv": cvv,
            },
            //"subscriptions": subscriptions,
            "email": email,
          })
          .then((value) => value
              .collection('chargerType')
              .add({'chargerType': chargerType}).then((v) => value
                  .collection('subscriptions')
                  .add({'subscriptions': subscriptions})))
          .catchError((error) => print("Failed to add user: $error"));
    }

    _validateField(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      return null;
    }

    // ignore for now
    /*int curMonth = DateTime.now().month;
    int curYear = DateTime.now().year;
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? selected = await showDatePicker(
          context: context,
          initialDate: DateTime(curYear, curMonth),
          firstDate: DateTime(curYear, curMonth),
          lastDate: DateTime(2050));
      if (selected != null && selected != DateTime(curYear, curMonth)) {
        setState(() {
          curYear = selected.year;
          curMonth = selected.month;
        });
      }
    } // _selectDate */

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add User"),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // text entries
              Container(
                // name
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newName,
                    //autocorrect: false,
                    decoration: const InputDecoration(hintText: 'Name'),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Container(
                // email
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newEmail,
                    //autocorrect: false,
                    decoration: const InputDecoration(hintText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Container(
                  // phone number
                  width: screenWidth,
                  padding: inputPadding,
                  child: TextFormField(
                      controller: newPhone,
                      //autocorrect: false,
                      decoration:
                          const InputDecoration(hintText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.next,
                      validator: _validateField)),
              Row(
                // rows to make things look pretty / to save on screen space
                children: [
                  Container(
                    //street
                    width: 180,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newStreet,
                        //autocorrect: false,
                        decoration: const InputDecoration(hintText: 'Street'),
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  ),
                  Container(
                    // city
                    width: 180,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newCity,
                        //autocorrect: false,
                        decoration: const InputDecoration(hintText: 'City'),
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    // state
                    width: 70,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newState,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                            hintText: 'State', counterText: ""),
                        maxLength: 2,
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  ),
                  Container(
                    // zip
                    width: 140,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newZip,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                            hintText: 'ZIP', counterText: ""),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        // accepts numbers only
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  ),
                  Container(
                    // country
                    width: 140,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newCountry,
                        //autocorrect: false,
                        decoration: const InputDecoration(hintText: 'Country'),
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  )
                ],
              ),
              Container(
                // credit card
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newCard,
                    //autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: 'Credit Card Number'),
                    keyboardType: TextInputType.number,
                    // accepts numbers only
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Row(
                children: [
                  Container(
                    padding: inputPadding,
                    child: const Text("Expiration"),
                  ),
                  Container(
                      // expiration month
                      width: 60,
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                      child: TextFormField(
                          controller: newExpirMon,
                          //autocorrect: false,
                          decoration: const InputDecoration(
                              hintText: 'MM', counterText: ""),
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textInputAction: TextInputAction.next,
                          validator: _validateField)),
                  const Text("/"),
                  Container(
                      // expiration year
                      width: 60,
                      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 10.0),
                      child: TextFormField(
                          controller: newExpirYr,
                          //autocorrect: false,
                          decoration: const InputDecoration(
                              hintText: 'YYYY', counterText: ""),
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textInputAction: TextInputAction.next,
                          validator: _validateField)),
                  Container(
                    // cvv
                    width: 60,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newCvv,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                            hintText: 'CVV', counterText: ""),
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  )
                ],
              ),
              Container(
                // charger. look into onSubmitted field to keep ongoing list
                width: 280,
                padding: inputPadding,
                child: TextFormField(
                    controller: newChargerType,
                    //autocorrect: false,
                    decoration: const InputDecoration(hintText: 'Charger Type'),
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Container(
                // subscriptions. look into onSubmitted field to keep ongoing list
                width: 280,
                padding: inputPadding,
                child: TextFormField(
                    controller: newSubscriptions,
                    //autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: 'Subscriptions'),
                    textInputAction: TextInputAction.done,
                    validator: _validateField),
              ),
              Padding(
                  padding: inputPadding,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _addUser();
                      }
                    },
                    child: const Text("Sign Up"),
                  )),
              Padding(
                  padding: inputPadding,
                  child: ElevatedButton(
                    onPressed: () => goToMaps(context),
                    child: const Text("Maps Screen"),
                  )),
              /*TextButton(
                  onPressed: addUser,
                  child: const Text("Add User")), // submit button
              TextButton(
                  onPressed: () => goToMaps(context),
                  child: const Text("Maps Screen")),*/ // navigation button
            ],
          )),
    );
  } // build
} // _AddUserState

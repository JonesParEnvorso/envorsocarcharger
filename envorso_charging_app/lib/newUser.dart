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
      home: const AddPID(),
    );
  }
}

// create new user from user input
class AddPID extends StatefulWidget {
  const AddPID({Key? key}) : super(key: key);
  @override
  _AddPID createState() => _AddPID();
}

class _AddPID extends State<AddPID> {
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
  final List<String> chargerTypes = <String>[];
  // subscriptions will be array
  final newSubscriptions = TextEditingController();

  bool _j1772Selected = false;
  bool _chademoSelected = false;
  bool _saeComboSelected = false;

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

    _AddPID() async {
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
      //String chargerType = newChargerType.text;
      if (_j1772Selected) {
        chargerTypes.add('J1772');
      }
      if (_chademoSelected) {
        chargerTypes.add('CHAdeMO');
      }
      if (_saeComboSelected) {
        chargerTypes.add('SAE Combo CCS');
      }
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
              .add({'chargerType': chargerTypes}).then((v) => value
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
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // text entries
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'User Info',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                // namw
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newName,
                    //autocorrect: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name Last Name',
                    ),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Username',
                    ),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Phone Number',
                      ),
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
                    width: screenWidth / 2.25,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newStreet,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Home street',
                        ),
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  ),
                  Container(
                    // city
                    width: screenWidth / 2.25,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newCity,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'City',
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateField),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    // state
                    width: screenWidth / 4.5,
                    padding: inputPadding,

                    // WILL BE DROP DOWN

                    /*child: DropdownButton(
                      value: selectedValue, 

                    )*/
                  ),
                  Container(
                    // zip
                    width: screenWidth / 3,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newZip,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'ZIP',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        // accepts numbers only
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => {
                              if (newZip.text.length == 5)
                                {FocusScope.of(context).nextFocus()}
                            },
                        validator: _validateField),
                  ),
                  Container(
                    // country
                    width: screenWidth / 3,
                    padding: inputPadding,

                    // WILL BE DROP DOWN

                    /*child: DropdownButton(

                       ),*/
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Credit Card #',
                    ),
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
                    child: const Text("Expiration:"),
                  ),

                  // WILL BE DROP DOWN

                  /*Container(
                      // expiration month
                      width: screenWidth / 7,
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
                          onChanged: (value) => {
                                if (newExpirMon.text.length == 2)
                                  {FocusScope.of(context).nextFocus()}
                              },
                          validator: _validateField)),
                  const Text("/"),
                  Container(
                      // expiration year
                      width: screenWidth / 6,
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
                          onChanged: (value) => {
                                if (newExpirYr.text.length == 4)
                                  {FocusScope.of(context).nextFocus()}
                              },
                          validator: _validateField)),*/
                  Container(
                    // cvv
                    width: screenWidth / 6,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newCvv,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'CVV',
                        ),
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.next,
                        onChanged: (value) => {
                              if (newCvv.text.length == 3)
                                {FocusScope.of(context).nextFocus()}
                            },
                        validator: _validateField),
                  )
                ],
              ),
              Container(
                padding: inputPadding,
                child: RichText(
                    text: const TextSpan(
                        text: 'Charger Ports:',
                        style: TextStyle(color: Colors.black, fontSize: 24))),
              ),
              Row(children: [
                // row of charger buttons. change background color on selection and reduce button size
                // push all selected buttons to charger array
                // images are from: https://chargehub.com/en/electric-car-charging-guide.html
                Column(
                  children: [
                    IconButton(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        iconSize: 90,
                        color: Colors.blue,
                        onPressed: () => {
                              setState(() {
                                _j1772Selected = !_j1772Selected;
                              })
                            },
                        icon: Image.asset(
                          'assets/images/Plug-Icon-J1772.png',
                          color: _j1772Selected ? Colors.blue : Colors.black,
                        )),
                    RichText(
                        text: const TextSpan(
                            text: 'J1772',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        iconSize: 90,
                        onPressed: () => {
                              setState(() {
                                _chademoSelected = !_chademoSelected;
                              })
                            },
                        icon: Image.asset('assets/images/Plug-Icon-CHAdeMO.png',
                            color:
                                _chademoSelected ? Colors.blue : Colors.black)),
                    RichText(
                        text: const TextSpan(
                            text: 'CHAdeMO',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                        iconSize: 90,
                        onPressed: () => {
                              setState(() {
                                _saeComboSelected = !_saeComboSelected;
                              })
                            },
                        icon: Image.asset(
                            'assets/images/Plug-Icon-J1772-Combo.png',
                            color: _saeComboSelected
                                ? Colors.blue
                                : Colors.black)),
                    RichText(
                        text: const TextSpan(
                            text: 'SAE Combo CCS',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)))
                  ],
                ),
                /*IconButton(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 20.0, 10.0),
                    iconSize: 90,
                    onPressed: () => print("J1772"),
                    icon: Image.asset('assets/images/Plug-Icon-J1772.png')),
                IconButton(
                    padding: const EdgeInsets.fromLTRB(5.0, 10.0, 20.0, 10.0),
                    iconSize: 90,
                    onPressed: () => print("CHAdeMO"),
                    icon: Image.asset('assets/images/Plug-Icon-CHAdeMO.png')),
                IconButton(
                  padding: const EdgeInsets.fromLTRB(5.0, 10.0, 20.0, 10.0),
                  iconSize: 90,
                  onPressed: () => print("SAE Combo CCS"),
                  icon: Image.asset('assets/images/Plug-Icon-J1772-Combo.png'),
                ),*/
              ]),

              /*Container(
                // charger. look into onSubmitted field to keep ongoing list
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                  controller: newChargerType,
                  //autocorrect: false,
                  decoration: const InputDecoration(hintText: 'Charger Type'),
                  textInputAction: TextInputAction.go,
                  validator: _validateField,
                  onEditingComplete: () => {
                    chargerTypes.add(newChargerType.text),
                    newChargerType.clear()
                  },
                ),
              ),*/
              Container(
                // subscriptions. look into onSubmitted field to keep ongoing list
                width: screenWidth,
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
                        _AddPID();
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
                  onPressed: AddPID,
                  child: const Text("Add User")), // submit button
              TextButton(
                  onPressed: () => goToMaps(context),
                  child: const Text("Maps Screen")),*/ // navigation button
            ],
          )),
    );
  } // build
} // _AddPIDState

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'servicesList.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

void main() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/
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
      home: const AddPID(
        documentId: "",
      ),
    );
  }
}

// create new user from user input
class AddPID extends StatefulWidget {
  const AddPID({Key? key, required this.documentId}) : super(key: key);

  final String documentId;

  @override
  _AddPID createState() => _AddPID();
}

class _AddPID extends State<AddPID> {
  String newState = 'State';
  List<String> states = [
    'State',
    'AL',
    'AK',
    'AS',
    'AZ',
    'AR',
    'CA',
    'CO',
    'CT',
    'DE',
    'DC',
    'FM',
    'FL',
    'GA',
    'GU',
    'HI',
    'ID',
    'IL',
    'IN',
    'IA',
    'KS',
    'KY',
    'LA',
    'ME',
    'MH',
    'MD',
    'MA',
    'MI',
    'MN',
    'MS',
    'MO',
    'MT',
    'NE',
    'NV',
    'NH',
    'NJ',
    'NM',
    'NY',
    'NC',
    'ND',
    'MP',
    'OH',
    'OK',
    'OR',
    'PW',
    'PA',
    'PR',
    'RI',
    'SC',
    'SD',
    'TN',
    'TX',
    'UT',
    'VT',
    'VI',
    'VA',
    'WA',
    'WV',
    'WI',
    'WY'
  ];

  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getImgs();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey();

  final List<String> _selectedItems = [];

  // address consists of: city, state, street, zip
  final newCity = TextEditingController();
  final newStreet = TextEditingController();
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

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;

  // chargerType and Subscriptions still need to be fully updated
  // charger type will be array
  final newChargerType = TextEditingController();
  final List<String> chargerTypes = <String>[];

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
    const inputPadding = EdgeInsets.all(5);

    goToServices(BuildContext context) {
      // add documentId as a field to the next page
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ServicesList()));
    }

    OutlineInputBorder? border;

    @override
    void initState() {
      super.initState();
      border = OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.7),
          width: 2.0,
        ),
      );
    }

    @override
    void dispose() {
      //_controller.dispose();
      newName.dispose();
      newEmail.dispose();
      newPhone.dispose();
      newCity.dispose();
      newStreet.dispose();
      newZip.dispose();
      newCountry.dispose();
      newCard.dispose();
      newExpirMon.dispose();
      newExpirYr.dispose();
      newCvv.dispose();
      newChargerType.dispose();

      super.dispose();
    }

    Future<void> _addPID() {
      //String name = newName.text; // split name into first and last

      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String firstName;
      String lastName;
      if (!cardHolderName.contains(" ")) {
        firstName = cardHolderName;
        lastName = "";
      } else {
        firstName = cardHolderName.substring(0, cardHolderName.indexOf(" "));
        lastName = cardHolderName.substring(cardHolderName.indexOf(" ") + 1);
      }
      String email = newEmail.text;
      String phoneNumber = newPhone.text;
      String city = newCity.text;
      String street = newStreet.text;
      String state = newState;
      String zip = newZip.text;
      String creditCard = cardNumber;
      String expir = expiryDate;
      String cvv = cvvCode;
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

      DocumentReference newUser =
          FirebaseFirestore.instance.collection('users').doc(widget.documentId);

      return newUser
          .set({
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
              "exp": expir,
              "cvv": cvv,
            },
            "email": email,
          }, SetOptions(merge: true))
          .then((value) => newUser
              .collection('chargerType')
              .add({'chargerType': chargerTypes}))
          .catchError((Object error) => Future.error(Exception("$error")));
    } // _AddPID

    _handleInput() {
      _addPID();
      // clear text entries
      newName.clear();
      newPhone.clear();
      newChargerType.clear();
      newEmail.clear();
      newState = 'State';
      newStreet.clear();
      newCity.clear();
      newZip.clear();
      newCountry.clear();
      cardHolderName = '';
      cardNumber = '';
      expiryDate = '';
      cvvCode = '';
      goToServices(context);
    }

    _validateField(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      return null;
    }

    return Scaffold(
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // text entries
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(5),
                  child: const Text(
                    'User Info',
                    style: TextStyle(fontSize: 20),
                  )),
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

              // Home Street
              Container(
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
              Row(
                children: <Widget>[
                  Container(
                    // city
                    width: screenWidth / 2,
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
                  ),
                  Container(
                    //ZIP
                    width: screenWidth / 4,
                    padding: inputPadding,
                    child: TextFormField(
                        controller: newZip,
                        //autocorrect: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'ZIP',
                          counterText: '',
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
                    // state dropdown
                    margin: const EdgeInsets.all(5.0),
                    height: 60,
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        //dimensions: EdgeInsetsGeometry(50),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        side: BorderSide(
                            width: 1.0,
                            style: BorderStyle.solid,
                            color: Colors.grey),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton(
                          value: newState,
                          onChanged: (String? newValue) {
                            setState(() {
                              newState = newValue!;
                            });
                          },
                          // Down Arrow Icon
                          icon: const Icon(Icons.keyboard_arrow_down),

                          // Array list of items
                          items: states.map((states) {
                            return DropdownMenuItem(
                              value: states,
                              child: new Text(states),
                            );
                          }).toList(),
                          // After selecting the desired option,it will
                          // change button value to selected value
                        ),
                      ),
                    ),
                  )
                ], // end children
              ),
              TextButton(
                onPressed: () => {},
                child: const Text('Why is Credit Card info needed?',
                    style: TextStyle(color: Color(0xff096B72))),
              ),
              Container(
                // User's name
                // Required
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name Last Name',
                    ),
                    //keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Container(
                // Credit Card Number
                // optional
                // NEED TO DO
                  // limit digits
                  // private? 
                  // Add hint text
                width: screenWidth,
                padding: inputPadding,
                child: TextFormField(
                    controller: newCard,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CC number',
                    ),
                    //keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateField),
              ),
              Row(children: <Widget>[
                Container(
                  // expiration date
                  // NEED TO DO
                    // Include '/' after first two digits automatically
                    // limit to 4 inputs (5 if I can't figure out ^)
                  width: screenWidth / 2,
                  padding: inputPadding,
                  child: TextFormField(
                      
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Exp. Date',
                      ),
                      keyboardType: TextInputType.datetime,
                      
                      textInputAction: TextInputAction.next,
                      validator: _validateField),
                ),
                Container(
                  // cvv
                  // NEED TO DO: 
                    // Limit to 4 number
                    // make private
                  width: screenWidth / 2,
                  padding: inputPadding,
                  child: TextFormField(
                      
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: _validateField),
                ),
              ]),

              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Plug types (Can Add Later):',
                    style: TextStyle(fontSize: 20),
                  )),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: checkBoxListTileModel.length,
                  itemBuilder: (BuildContext context, int index) {
                    // ignore: unnecessary_new
                    return Card(
                      // ignore: unnecessary_new
                      child: new Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            // ignore: unnecessary_new
                            new CheckboxListTile(
                              onChanged: (bool? val) {
                                itemChange(val, index);
                              },
                              activeColor: Color(0xff096B72),
                              dense: true,
                              title: Text(
                                checkBoxListTileModel[index].title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              value: checkBoxListTileModel[index].isCheck,
                              secondary: Container(
                                height: 50,
                                width: 50,
                                child: Image.asset(
                                  checkBoxListTileModel[index].img,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),

              Container(
                  // continue button
                  padding: inputPadding,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          newState != 'State') {
                        //_addPID();
                        _handleInput();
                      }
                    },
                    child: const Text("Continue"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xff096B72)),
                    ),
                  )),
            ],
          )),
    );
  }

  void itemChange(bool? val, int index) {
    if (index == 1) {
      _chademoSelected = !_chademoSelected;
    } else if (index == 2) {
      _j1772Selected = !_j1772Selected;
    } else {
      _saeComboSelected = !_saeComboSelected;
    }
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  } // build
} // _AddPIDState

class CheckBoxListTileModel {
  int imgId;
  String img;
  String title;
  bool? isCheck;

  CheckBoxListTileModel(
      {required this.imgId,
      required this.img,
      required this.title,
      required this.isCheck});

  static List<CheckBoxListTileModel> getImgs() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
        imgId: 1,
        img: 'assets/images/Plug-Icon-CHAdeMO.png',
        title: 'CHAdeMo',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        imgId: 2,
        img: 'assets/images/Plug-Icon-J1772.png',
        title: 'J1772',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        imgId: 3,
        img: 'assets/images/Plug-Icon-J1772-Combo.png',
        title: 'J1772 Combo',
        isCheck: false,
      )
    ];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:envorso_charging_app/firstlaunch.dart';
import 'package:envorso_charging_app/servicesList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings.dart';
import 'firebaseFunctions.dart';
import 'startUp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnRoute Account Settings',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class ChangePID extends StatefulWidget {
  const ChangePID({Key? key}) : super(key: key);
  @override
  _ChangePID createState() => _ChangePID();
}

class _ChangePID extends State<ChangePID> {
  goToSettings(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  goToFirstLaunch(BuildContext context) {}

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

  // address consists of: city, state, street, zip
  final newCity = TextEditingController();
  final newStreet = TextEditingController();
  final newZip = TextEditingController();
  final newCountry = TextEditingController();
  // card consists of: number, expiration, and cvv
  final newCard = TextEditingController();
  final newExpiry = TextEditingController();
  final newCvv = TextEditingController();

  bool isCardNumVisible = false;
  bool isCvvVisible = false;

  final newName = TextEditingController();
  final newUsername = TextEditingController();
  final newPhone = TextEditingController();

  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getImgs();

  final List<String> chargerTypes = <String>[];
  bool _j1772Selected = false;
  bool _chademoSelected = false;
  bool _saeComboSelected = false;

  OutlineInputBorder? border;

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  @override
  void initState() {
    _j1772Selected = false;
    _chademoSelected = false;
    _saeComboSelected = false;
    super.initState();
    isCardNumVisible = false;
    isCvvVisible = false;
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
  }

  @override
  void dispose() {
    newName.clear();
    newPhone.clear();
    newUsername.clear();
    newStreet.clear();
    newCity.clear();
    newZip.clear();
    newCountry.clear();
    newExpiry.clear();
    newCard.clear();
    newCvv.clear();
    newName.dispose();
    newUsername.dispose();
    newPhone.dispose();
    newCity.dispose();
    newStreet.dispose();
    newZip.dispose();
    newCountry.dispose();
    newCard.dispose();
    newExpiry.dispose();
    newCvv.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    const inputPadding = EdgeInsets.all(5);

    _updatePID() async {
      final FirebaseAuth auth = FirebaseAuth.instance;
      String uId;
      if (auth.currentUser == null) {
        print('No user! How did you even get here?');
        return;
      } else {
        uId = auth.currentUser!.uid;
      }

      if (_j1772Selected) {
        chargerTypes.add('J1772');
      }
      if (_chademoSelected) {
        chargerTypes.add('CHAdeMO');
      }
      if (_saeComboSelected) {
        chargerTypes.add('SAE Combo CCS');
      }

      /*firebaseFunctions.updateAccount(
          uId,
          newUsername.text,
          newPhone.text,
          newStreet.text,
          newCity.text,
          newZip.text,
          newState,
          newName.text,
          newCard.text,
          newExpiry.text,
          newCvv.text,
          chargerTypes);*/

      newUsername.clear();
      newPhone.clear();
      newStreet.clear();
      newCity.clear();
      newZip.clear();
      newState = 'State';
      newName.clear();
      newCard.clear();
      newExpiry.clear();
      newCvv.clear();
      chargers = [];
      itemChange(false, 0);
      itemChange(false, 1);
      itemChange(false, 2);
    }

    _signOut() async {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user! How did you even get here?');
        return;
      }

      await FirebaseAuth.instance.signOut().then((res) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const StartUp()));
      });
      // go to firstLaunch
    }

    return Scaffold(
      body: Form(
          //key: _formKey,
          child: ListView(
        children: <Widget>[
          Container(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                  onPressed: () => goToSettings(context),
                  child: const Icon(Icons.arrow_back),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(8)),
                      backgroundColor: MaterialStateProperty.all(
                          const Color(0xff096B72)), // Button color
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.black;
                        } // Splash color
                      })))),
          // text entries. no need for validation
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(5),
              child: const Text(
                'User Info',
                style: TextStyle(fontSize: 20),
              )),
          Container(
            // username
            width: screenWidth,
            padding: inputPadding,
            child: TextFormField(
              controller: newUsername,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
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
              )),

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
            ),
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
                ),
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
                ),
              ),
              Container(
                height: 80,
                width: screenWidth / 5,
                margin: const EdgeInsets.all(5.0),
                decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  side: BorderSide(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Colors.white),
                )),
                child: DropdownButtonFormField(
                  items: states.map((states) {
                    return DropdownMenuItem(
                      value: states,
                      child: Text(states),
                    );
                  }).toList(),
                  value: newState,
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        newState = newValue;
                      }
                    });
                  },
                  elevation: 5,
                  isDense: true,
                  //iconSize: 20.0,
                ),
              ),
            ], // end children
          ),
          TextButton(
              child: const Text('Why is Credit Card info needed?',
                  style: TextStyle(color: Color(0xff096B72))),
              onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Credit Card Info'),
                      content: const SingleChildScrollView(
                          child: Text(
                              'CREDIT CARD INFORMATION IS OPTIONAL\n\nWe will not charge you any amount of money for using our service, but in order to use certain charging companies chargers, your credit card informatoin will be needed for them. \n\ne.g. We won\'t charge you, but we make it easier for you to use services that do charge you.')),
                      actions: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                              primary: const Color(0xff096B72)),
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  )),
          // start of credit card
          Container(
            // User's name
            width: screenWidth,
            padding: inputPadding,
            child: TextFormField(
              controller: newName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Cardholder Name',
                hintText: 'First Name Last Name',
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          Container(
            // Credit Card Number
            width: screenWidth,
            padding: inputPadding,
            child: TextFormField(
              controller: newCard,
              obscureText: !isCardNumVisible,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'CC number',
                hintText: '#### #### #### ####',
                counterText: '',
                suffixIcon: IconButton(
                  icon: Icon(
                    isCardNumVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xff096B72),
                  ),
                  onPressed: () {
                    setState(() {
                      isCardNumVisible = !isCardNumVisible;
                    });
                  },
                ),
              ),
              onChanged: (value) => {
                if (newCard.text.length == 16)
                  {FocusScope.of(context).nextFocus()}
              },
              maxLength: 16,
              textInputAction: TextInputAction.next,
            ),
          ),
          Row(children: <Widget>[
            Container(
                // expiration date
                width: screenWidth / 2,
                padding: inputPadding,
                child: TextFormField(
                  // commented this out because this forces the Exp. Date field to
                  // have data in it, which isn't necessarily what we want since
                  // all credit card data is optional, minus the user's name
                  /*validator: (String? val) {
                        return (val != null && !val.contains('/'))
                            ? 'Missing /'
                            : null;
                      },*/
                  controller: newExpiry,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Exp. Date',
                    hintText: 'XX/XX',
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  onChanged: (value) => {
                    if (newExpiry.text.length == 5)
                      {FocusScope.of(context).nextFocus()}
                  },
                  textInputAction: TextInputAction.next,
                  //validator: _validateField),
                )),
            Container(
              // cvv
              width: screenWidth / 2,
              padding: inputPadding,
              child: TextFormField(
                controller: newCvv,
                obscureText: !isCvvVisible,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'CVV',
                  counterText: '',
                  suffixIcon: IconButton(
                    icon: Icon(
                      isCvvVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xff096B72),
                    ),
                    onPressed: () {
                      setState(() {
                        isCvvVisible = !isCvvVisible;
                      });
                    },
                  ),
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
          ]),
          // end of credit card
          Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Plug types:',
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
                          activeColor: const Color(0xff096B72),
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
              // update button
              padding: inputPadding,
              child: ElevatedButton(
                onPressed: () {
                  _updatePID();
                },
                child: const Text("Update Account Info"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xff096B72)),
                ),
              )),
          Container(
              // sign out button
              padding: inputPadding,
              child: ElevatedButton(
                onPressed: () {
                  _signOut();
                },
                child: const Text("Sign Out"),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xff096B72)),
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
}

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
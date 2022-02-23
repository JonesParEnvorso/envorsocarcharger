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
  final newExpiry = TextEditingController();
  final newCvv = TextEditingController();

  final newName = TextEditingController();
  final newUsername = TextEditingController();
  final newPhone = TextEditingController();

  bool isCardNumVisible = false;
  bool isCvvVisible = false;

  // variables below currently do nothing
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;

  // chargerType and Subscriptions still need to be fully updated
  // charger type will be array
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

    final String docId = widget.documentId;

    goToServices(BuildContext context) {
      // add documentId as a field to the next page
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServicesList(
                    documentId: docId,
                  )));
    }

    OutlineInputBorder? border;

    @override
    void initState() {
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
      //_controller.dispose();
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

    Future<void> _addPID() {
      //String name = newName.text; // split name into first and last

      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      String firstName;
      String lastName;
      if (!newName.text.contains(" ")) {
        firstName = newName.text;
        lastName = "";
      } else {
        firstName = newName.text.substring(0, newName.text.indexOf(" "));
        lastName = newName.text.substring(newName.text.indexOf(" ") + 1);
      }
      String username = newUsername.text;
      String phoneNumber = newPhone.text;
      String city = newCity.text;
      String street = newStreet.text;
      String state = newState;
      String zip = newZip.text;
      String creditCard = newCard.text;
      String expir = newExpiry.text;
      String cvv = newCvv.text;

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
          .update(
            {
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
              "username": username,
            }, /*SetOptions(merge: true)*/
          )
          .then((value) => newUser
              .collection('chargerType')
              .doc("chargers")
              .set({'chargerType': chargerTypes}))
          .catchError((Object error) => Future.error(Exception("$error")));
    } // _AddPID

    _handleInput() {
      _addPID();
      // clear text entries
      newName.clear();
      newPhone.clear();
      newUsername.clear();
      newState = 'State';
      newStreet.clear();
      newCity.clear();
      newZip.clear();
      newCountry.clear();
      newExpiry.clear();
      newCard.clear();
      newCvv.clear();
      //cardHolderName = '';
      //cardNumber = '';
      //expiryDate = '';
      //cvvCode = '';
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
                          // After selecting the desired option,it will
                          // change button value to selected value
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
                              child: Text(states),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
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
                                  primary: Color(0xff096B72)),
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
                        isCardNumVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xff096B72),
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
                          isCvvVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xff096B72),
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

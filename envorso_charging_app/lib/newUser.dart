import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'mapScreen.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

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
  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getImgs();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey = GlobalKey();

  final List<String> _selectedItems = [];

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
      DocumentReference newUser =
          FirebaseFirestore.instance.collection('users').doc(widget.documentId);
      await newUser.update({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'countryCode': '+1', // default to +1 since we are only focusing on USA
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
      });
      /*.then((value) => value
              .collection('chargerType')
              .add({'chargerType': chargerTypes}).then((v) => value
                  .collection('subscriptions')
                  .add({'subscriptions': subscriptions})))
          .catchError((error) => print("Failed to add user: $error"));*/

      await newUser
          .collection('chargerType')
          .add({'chargerType': chargerTypes});
      await newUser
          .collection('subscriptions')
          .add({'subscriptions': subscriptions});

      goToMaps(context);
    } // _AddPID

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
                  padding: const EdgeInsets.all(10),
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
                    width: screenWidth / 1.35,
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
                ], // end children
              ),
              TextButton(
                onPressed: () => {},
                child: const Text('Why is Credit Card info needed?',
                    style: TextStyle(color: Color(0xff096B72))),
              ),
              // CREDIT CARD INFORMATION
              Container(
                child: CreditCardForm(
                  formKey: formKey,
                  obscureCvv: true,
                  obscureNumber: true,
                  cardHolderName: cardHolderName,
                  cardNumber: cardNumber,
                  cvvCode: cvvCode,
                  isHolderNameVisible: true,
                  isCardNumberVisible: true,
                  isExpiryDateVisible: true,
                  expiryDate: expiryDate,
                  themeColor: Color(0xff096B72),
                  textColor: Colors.black,
                  cardHolderDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.black),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: border,
                    enabledBorder: border,
                    labelText: 'Card Holder',
                    hintText: 'First Name Last Name',
                  ),
                  cardNumberDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CC Number',
                    hintText: 'XXXX XXXX XXXX XXXX',
                    hintStyle: const TextStyle(color: Colors.black),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: border,
                    enabledBorder: border,
                  ),
                  expiryDateDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.black),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: border,
                    enabledBorder: border,
                    labelText: 'Exp. Date',
                    hintText: 'XX/XX',
                  ),
                  cvvCodeDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.black),
                    labelStyle: const TextStyle(color: Colors.black),
                    focusedBorder: border,
                    enabledBorder: border,
                    labelText: 'CVV',
                    hintText: 'XXX',
                  ),
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ),
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
                        padding: EdgeInsets.all(10.0),
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
                                style: TextStyle(
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
                      if (_formKey.currentState!.validate()) {
                        _AddPID();
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

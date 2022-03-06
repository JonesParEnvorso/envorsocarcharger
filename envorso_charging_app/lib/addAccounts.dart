import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'enRouteAccountSettings.dart';
import 'settings.dart';
import 'firebaseFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This file allows users to add services that ENRoute has in it's database
// it will show services users currently have as well

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add Accounts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class AddAcounts extends StatefulWidget {
  const AddAcounts({Key? key}) : super(key: key);
  @override
  _AddAcounts createState() => _AddAcounts();
}

class _AddAcounts extends State<AddAcounts> {
  goToSettings(BuildContext context) {
    Navigator.pop(context);
    //Navigator.push(
    //    context, MaterialPageRoute(builder: (context) => SettingsScreen()));
  }

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late AnimationController aniController;
  List<CheckBoxListTileModel> checkBoxListTileModel = [];

  // boolean for loading indicator
  bool isLoading = true;

  // list to store all service info
  List<Map<String, String>> services = [];
  String zip = '';

  // list of users selected services. will be filled with data from the database
  List<String> userServices = [];

  @override
  void initState() {
    //aniController = AnimationController(vsync: this);
    fillServices();
    super.initState();
  }

  // grab all unique services from database
  fillServices() async {
    String uId = firebaseFunctions.getUId();
    if (uId == '') {
      print("How did you get here?");
      return;
    }

    services = await firebaseFunctions.getServices(uId);

    var doc = FirebaseFirestore.instance.collection('users').doc(uId);
    await doc.get().then((DocumentSnapshot docSnap) {
      zip = docSnap.get(FieldPath(const ['address', 'zip']));
    });

    List<CheckBoxListTileModel> temp =
        await CheckBoxListTileModel.getServices(services, zip);

    setState(() {
      checkBoxListTileModel = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TO DO: Make this function similar to charging buttons on enRouteAccountSettings
    // make Elevated button stay at bottom of screen regardless of scroll
    _updateServices() async {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < checkBoxListTileModel.length; i++) {
        if (checkBoxListTileModel[i].isCheck == true) {
          userServices.add(checkBoxListTileModel[i].databaseTitle);
        }
      }

      String uId = firebaseFunctions.getUId();
      if (uId == '') {
        return;
      }

      await firebaseFunctions.addServices(uId, userServices);
      await fillServices();

      setState(() {
        userServices = [];
        isLoading = false;
      });
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Padding(
            //flex: 1,
            padding: const EdgeInsets.all(10),
            child: isLoading
                ? const Center(
                    // loading icon
                    child: CircularProgressIndicator(
                      color: Color(0xff096B72),
                    ),
                  )
                : ListView(children: <Widget>[
                    Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                            child: ElevatedButton(
                                onPressed: () => goToSettings(context),
                                child: const Icon(Icons.arrow_back),
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                        const CircleBorder()),
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(8)),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color(
                                            0xff096B72)), // Button color
                                    overlayColor: MaterialStateProperty
                                        .resolveWith<Color?>((states) {
                                      if (states
                                          .contains(MaterialState.pressed)) {
                                        return Colors.black;
                                      }
                                      return null; // Splash color
                                    })))),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 25, 5, 0),
                          child: const Text(
                            'Add Services',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const <Widget>[
                              Icon(
                                Icons.stars,
                                color: Color(0xff096B72),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Local',
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Icon(
                                Icons.monetization_on,
                                color: Color(0xffCFB406),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Fees apply',
                                style: TextStyle(fontSize: 15),
                              ),
                            ])),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
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
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.stars,
                                              color:
                                                  checkBoxListTileModel[index]
                                                          .local
                                                      ? const Color(0xff096B72)
                                                      : Colors.white,
                                            ),
                                            if (checkBoxListTileModel[index]
                                                .money) ...[
                                              const Icon(
                                                Icons.monetization_on,
                                                color: Color(0xffCFB406),
                                              ),
                                            ],
                                          ],
                                        )),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                    ElevatedButton(
                        onPressed: () => _updateServices(),
                        child: Text('Update Services'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xff096B72)))),
                  ])));
  }

  void itemChange(bool? val, int index) {
    setState(() {
      checkBoxListTileModel[index].isCheck = val;
    });
  }
}

class CheckBoxListTileModel {
  int id;
  bool local;
  bool money;
  String title;
  bool? isCheck;
  String databaseTitle;

  CheckBoxListTileModel(
      {required this.id,
      required this.local,
      required this.money,
      required this.title,
      required this.isCheck,
      required this.databaseTitle});

  static Future<List<CheckBoxListTileModel>> getServices(
      List<Map<String, String>> services, String zip) async {
    List<CheckBoxListTileModel> list = [];

    // grabs network or name of charger, zip code, and price of charge.
    for (int i = 0; i < services.length; i++) {
      String? title;
      bool money;
      bool local;
      bool isCheck;
      String? databaseTitle;

      title = services[i]['displayName'];
      databaseTitle = services[i]['databaseName'];

      // following logic will have to be changed as we find more information on the price of chargers
      if (services[i]['price'] == '' || services[i]['price'] == 'Free') {
        money = false;
      } else {
        money = true;
      }

      if (services[i]['zip'].toString() == zip) {
        local = true;
      } else {
        local = false;
      }

      if (services[i]['inUser'] == 'true') {
        isCheck = true;
      } else {
        isCheck = false;
      }

      // isCheck should be true if the service is in the user's document

      if (title != null && databaseTitle != null) {
        list.add(CheckBoxListTileModel(
            id: i,
            local: local,
            money: money,
            title: title,
            isCheck: isCheck,
            databaseTitle: databaseTitle));
      }
    }

    return list;
  }
}

import 'package:envorso_charging_app/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'mapScreen.dart';
import 'chargeStation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebaseFunctions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Services List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

List<Map<String, dynamic>> chargers = [];

Chargers chargeList = Chargers();

// fills the list with the result from the database
_fillChargerList() async {
  chargers = await chargeList.pullChargers(46.999883, -120.544755);
  //chargers2 = await chargeList.pullServices(46.999883, -120.544755);
}

//List<CheckBoxListTileModel> checkBoxListTileModel = [];

class ServicesList extends StatefulWidget {
  const ServicesList({Key? key, required this.uId}) : super(key: key);

  final String uId;
  @override
  _ServicesList createState() => _ServicesList();
}

class _ServicesList extends State<ServicesList> with TickerProviderStateMixin {
  //checkBoxListTileModel = CheckBoxListTileModel.getServices();

  goToMap(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapScreen()));
  }

  // list to store service data
  final List<String> services = <String>[];

  List<String> chargers2 = [];
  List<CheckBoxListTileModel> checkBoxListTileModel = [];

  late AnimationController aniController;

  // boolean for loading indicator
  bool isLoading = true;

  FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  @override
  void initState() {
    aniController = AnimationController(vsync: this);
    _fillServices();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _fillServices() async {
    await _fillChargerList();
    String zip = '';
    var doc = FirebaseFirestore.instance.collection('users').doc(widget.uId);
    await doc.get().then((DocumentSnapshot docSnap) {
      zip = docSnap.get(FieldPath(const ['address', 'zip']));
    });
    List<CheckBoxListTileModel> temp =
        await CheckBoxListTileModel.getServices(zip);
    setState(() {
      checkBoxListTileModel = temp;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // handle input
    _addServices() {
      for (int i = 0; i < checkBoxListTileModel.length; i++) {
        if (checkBoxListTileModel[i].isCheck == true) {
          services.add(checkBoxListTileModel[i].title);
        }
      }

      firebaseFunctions.addServices(widget.uId, services);

      goToMap(context);
    }

    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(children: <Widget>[
            Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(5),
                child: const Text(
                  'Services',
                  style: TextStyle(fontSize: 20),
                )),
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
            isLoading // starts off as true, changes to false once list has been loaded in
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff096B72),
                    ),
                  )
                : ListView.builder(
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.stars,
                                          color:
                                              checkBoxListTileModel[index].local
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
            Container(
                // continue button
                child: ElevatedButton(
              onPressed: () => _addServices(),
              child: const Text("Continue"),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xff096B72)),
              ),
            )),
          ])),
    );
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

  CheckBoxListTileModel(
      {required this.id,
      required this.local,
      required this.money,
      required this.title,
      required this.isCheck});

  static Future<List<CheckBoxListTileModel>> getServices(String zip) async {
    List<CheckBoxListTileModel> list = [];

    // grabs network or name of charger, zip code, and price of charge.
    for (int i = 0; i < chargers.length; i++) {
      String title;
      bool money;
      bool local;

      if (chargers[i]['network'] == 'Non-Networked') {
        title = chargers[i]['name'];
      } else {
        title = chargers[i]['network'];
      }

      // following logic will have to be changed as we find more information on the price of chargers
      if (chargers[i]['price'] == '' || chargers[i]['price'] == 'Free') {
        money = false;
      } else {
        money = true;
      }

      if (chargers[i]['zip'].toString() == zip) {
        local = true;
      } else {
        local = false;
      }

      if (local == true) {
        list.add(CheckBoxListTileModel(
            id: i, local: local, money: money, title: title, isCheck: true));
      } else {
        list.add(CheckBoxListTileModel(
            id: i, local: local, money: money, title: title, isCheck: false));
      }
    }

    return list;
    /*return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
        id: 0,
        local: false,
        money: true,
        title: 'ChargePoint',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        id: 1,
        local: false,
        money: true,
        title: 'Electrify America',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        id: 2,
        local: true,
        money: true,
        title: 'Greenlots',
        isCheck: true,
      ),
      CheckBoxListTileModel(
        id: 3,
        local: true,
        money: false,
        title: 'Electrical Vehicle Charging Station',
        isCheck: true,
      ),
      CheckBoxListTileModel(
        id: 4,
        local: true,
        money: true,
        title: 'Webasto',
        isCheck: true,
      )
    ];*/
  }
}

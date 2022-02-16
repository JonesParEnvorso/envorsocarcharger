import 'package:envorso_charging_app/speech_recognition.dart';
import 'package:flutter/material.dart';
import 'newUserEmail.dart';
import 'mapScreen.dart';

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

class ServicesList extends StatefulWidget {
  const ServicesList({Key? key}) : super(key: key);
  @override
  _ServicesList createState() => _ServicesList();
}

class _ServicesList extends State<ServicesList> {
  List<CheckBoxListTileModel> checkBoxListTileModel =
      CheckBoxListTileModel.getServices();

  goToMap(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: checkBoxListTileModel[index].local
                                          ? Color(0xff096B72)
                                          : Colors.white,
                                    ),
                                    if (checkBoxListTileModel[index].money) ...[
                                      Icon(
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
              onPressed: () => goToMap(context),
              child: const Text("Continue"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xff096B72)),
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
  static List<CheckBoxListTileModel> getServices() {
    return <CheckBoxListTileModel>[
      CheckBoxListTileModel(
        id: 1,
        local: false,
        money: true,
        title: 'ChargePoint',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        id: 2,
        local: false,
        money: true,
        title: 'Electrify America',
        isCheck: false,
      ),
      CheckBoxListTileModel(
        id: 3,
        local: true,
        money: true,
        title: 'Greenlots',
        isCheck: true,
      ),
      CheckBoxListTileModel(
        id: 4,
        local: true,
        money: false,
        title: 'Electrical Vehicle Charging Station',
        isCheck: true,
      ),
      CheckBoxListTileModel(
        id: 5,
        local: true,
        money: true,
        title: 'Webasto',
        isCheck: true,
      )
    ];
  }
}

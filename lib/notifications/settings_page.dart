import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sql_demo/front_page/home_page.dart';

import '/front_page/vocab_packages_front_page.dart';
import '/notifications/notification_api.dart';
import '/database/vocab_database.dart';
import '/database/model.dart';
import './schedule_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Page2 extends StatefulWidget {
  const Page2( {Key? key}) : super(key: key);

  @override
  _MyPage2State createState() => _MyPage2State();
}

class _MyPage2State extends State<Page2> with WidgetsBindingObserver{
  // Initial Selected Value
  List<int> hours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
  late int numNot = 1;
  late int startT = 6;
  late int endT = 18;
  late bool areScheduled = false;
  late String? dataBaseKey = null;
  final List<int> notificationNumbers = List<int>.generate(MAX_NUM_NOTIFICATIONS, (k) => k + 1);
  AppLifecycleState? _notification;
  late int? lastNot_year  = null;
  late int? lastNot_month = null;
  late int? lastNot_day   = null;
  late int? lastNot_hour  = null;
  late int? lastNot_min   = null;

  @override
  void initState() {
    NotificationApi.init(initScheduled: true);
    updateStoredValues();
    super.initState();
    listenNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  void listenNotifications() {
    NotificationApi.onNotifications.stream.listen(onClickedNotification);
  }


  // decide what to do when notification is clicked!!
  void onClickedNotification(String? payload) {
    bool renderHomePage = false;
    switch (_notification) {
      case AppLifecycleState.resumed:
        renderHomePage = false;
        break;
      case AppLifecycleState.inactive:
        renderHomePage = false;
        break;
      case AppLifecycleState.paused:
        renderHomePage = true;
        break;
      case AppLifecycleState.detached:
        renderHomePage = true;
        break;
    }
    if(renderHomePage) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    }
  }


  Future resetSchedule() async {
    NotificationApi.cancel();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      areScheduled = false;
      prefs.setBool('areScheduled', areScheduled);
    });
  }

  Future updateStoredValues() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.getInt('numNot') != null) {
      setState(() {
        numNot = prefs.getInt('numNot')!;
      });
    } else {
      prefs.setInt('numNot', numNot);
    }

    if(prefs.getInt('startT') != null) {
      setState(() {
        startT = prefs.getInt('startT')!;
      });
    } else {
      prefs.setInt('startT', startT);
    }

    if(prefs.getInt('endT') != null)   {
      setState(() {
        endT = prefs.getInt('endT')!;
      });
    } else {
      prefs.setInt('endT', endT);
    }

    if(prefs.getString('currentStudyPackageString') != null) {
      setState(() {
        dataBaseKey = prefs.getString('currentStudyPackageString')!;
      });
    }
    if(prefs.getBool('areScheduled') != null) {
      setState(() {
        areScheduled = prefs.getBool('areScheduled')!;
        if(dataBaseKey == null && areScheduled) {
            areScheduled = false;
            prefs.setBool('areScheduled', areScheduled);
          }
      });
    }
  }

  BoxDecoration boxDeco = BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: Colors.black87,
        //offset: const Offset(5.0, 5.0,), //Offset
        blurRadius: 2.0,
        spreadRadius: 2.0,
      )], //BoxShadow
  );

  final double widthBetweenRows = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Schedule", style: TextStyle(fontSize: 24),)),
      body: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(children: [Column(children: [SizedBox(height: widthBetweenRows)]), Column(children: [SizedBox(height: widthBetweenRows)]),]),
          TableRow(decoration: boxDeco,
            children: [Column(
              children: [Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Notifications per day', style: TextStyle(color: Colors.white, fontSize: 18))),],
            ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              DropdownButton<int>(
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white, fontSize: 18),
                hint: Text("Pick"),
                icon: const Icon(Icons.keyboard_arrow_down),
                value: numNot,
                items: notificationNumbers.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                    );
                  }).toList(),
                onChanged: (newVal) async {
                  setState(() {
                    numNot = newVal!;
                    });
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('numNot', numNot);
                  }
                  )]
              )
            ]
          ),
          TableRow(children: [Column(children: [SizedBox(height: widthBetweenRows)]), Column(children: [SizedBox(height: widthBetweenRows)]),]),
          TableRow(decoration: boxDeco,
              children: [Column(
                children: [Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Earliest notification', style: TextStyle(color: Colors.white, fontSize: 18))),],
              ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                          dropdownColor: Colors.black,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          hint: Text("Pick"),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          value: startT,
                          items: hours.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text((value).toString() + ':00'),
                            );
                          }).toList(),
                          onChanged: (newVal) async {
                            setState(() {
                              startT = (newVal!);
                              if(startT>endT && startT != 23){
                                endT = startT +1;
                              }
                            });
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setInt('startT', startT);
                          }
                      )]
                )
              ]
          ),
          TableRow(children: [Column(children: [SizedBox(height: widthBetweenRows)]), Column(children: [SizedBox(height: widthBetweenRows)]),]),
          TableRow(decoration: boxDeco,
              children: [Column(
                children: [Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Latest notification', style: TextStyle(color: Colors.white, fontSize: 18))),],
              ),
                Column(
                    children: [
                      DropdownButton<int>(
                          dropdownColor: Colors.black,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          hint: Text("Pick"),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          value: endT,
                          items: hours.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text((value).toString() + ':00'),
                            );
                          }).toList(),
                          onChanged: (newVal) async {
                            setState(() {
                              endT = newVal!;
                              if(startT>endT && endT != 0){
                                startT = endT - 1;
                              }
                            });
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setInt('endT', endT);
                          }
                      )]
                )
              ]
          ),
          TableRow(children: [Column(children: [SizedBox(height: widthBetweenRows)]), Column(children: [SizedBox(height: widthBetweenRows)]),]),
          TableRow(
            children: [
              Column(
                children: [turnOffNotifications()
                ],
              ),
              Column()
            ]
          ),
          TableRow(children: [Column(children: [SizedBox(height: widthBetweenRows)]), Column(children: [SizedBox(height: widthBetweenRows)]),]),
          TableRow(
              children: [
                Column(
                  children: [ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: areScheduled ? Colors.green : Colors.red, // background
                      onPrimary: Colors.white, // foreground
                    ),
                      onPressed: () async {
                        staticFunction.showErrorMessages(endT, startT, numNot, dataBaseKey, context);
                        final bool didUpdate = await staticFunction.scheduleNotificationsPerDay(endT, startT, numNot, dataBaseKey, true);
                        final prefs = await SharedPreferences.getInstance();
                        bool? areScheduledInternal = prefs.getBool('areScheduled');
                        setState(() {
                          areScheduled = (areScheduledInternal != null) ? areScheduledInternal : false;
                        });
                        },
                      child: Text("schedule notifications"),
                  )
                  ],
                ),
                Column()
              ]
          )
        ],
      )
    );
  }

  Widget turnOffNotifications() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.grey.shade700,
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('currentStudyPackageString');
        await resetSchedule();
        setState(() {
          areScheduled = false;
        });
        //Workmanager().cancelByUniqueName("dailyNotificationSchedule");
      },
      child: Text('Stop Notificaitons'),
    );
  }
}
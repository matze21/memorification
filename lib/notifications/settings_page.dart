import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sql_demo/front_page/home_page.dart';

import '/front_page/vocab_packages_front_page.dart';
import '/notifications/notification_api.dart';
import '/database/vocab_database.dart';
import '/database/model.dart';

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
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
    }
    if(prefs.getInt('startT') != null) {
      setState(() {
        startT = prefs.getInt('startT')!;
      });
    }
    if(prefs.getInt('endT') != null)   {
      setState(() {
        endT = prefs.getInt('endT')!;
      });
    }
    if(prefs.getString('currentStudyPackageString') != null) {
      setState(() {
        dataBaseKey = prefs.getString('currentStudyPackageString')!;
      });
    }
    if(prefs.getBool('areScheduled') != null)   {
      setState(() {
        areScheduled = prefs.getBool('areScheduled')!;
        if(dataBaseKey == null && areScheduled) {
            areScheduled = false;
            prefs.setBool('areScheduled', areScheduled);
          }
      });
    }
    if(areScheduled) {
      if(prefs.getInt('lastNot_year') != null)  { lastNot_year = prefs.getInt('lastNot_year')!; }
      if(prefs.getInt('lastNot_month') != null) { lastNot_month = prefs.getInt('lastNot_month')!; }
      if(prefs.getInt('lastNot_day') != null)   { lastNot_day = prefs.getInt('lastNot_day')!; }
      if(prefs.getInt('lastNot_hour') != null)  { lastNot_hour = prefs.getInt('lastNot_hour')!; }
      if(prefs.getInt('lastNot_min') != null)   { lastNot_min = prefs.getInt('lastNot_min')!; }

      if((lastNot_year != null) && (lastNot_month != null) && (lastNot_day != null) && (lastNot_hour != null) && (lastNot_min != null)) {
        final now = DateTime.now();
        final lastNot = DateTime(lastNot_year!, lastNot_month!, lastNot_day!, lastNot_hour!, lastNot_min!, 0);
        if (now.isAfter(lastNot)) {
          setState(() {
            areScheduled = false;
            prefs.setBool('areScheduled', areScheduled);
          });
        }
      }
    }
    if(areScheduled == false) {
      prefs.remove('lastNot_year');
      prefs.remove('lastNot_month');
      prefs.remove('lastNot_day');
      prefs.remove('lastNot_hour');
      prefs.remove('lastNot_min');
    }
  }

  BoxDecoration boxDeco = BoxDecoration(color: Colors.black38, border:
  Border(top:    BorderSide(color: Colors.white, width: 1, style: BorderStyle.solid),
  bottom: BorderSide(color: Colors.white, width: 1, style: BorderStyle.solid),
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notification Schedule", style: TextStyle(fontSize: 24),)),
      body: Table(
        columnWidths: {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(decoration: boxDeco,
            children: [Column(
              children: [Text('How many notifications per day would you like to receive'
                , style: TextStyle(color: Colors.white, fontSize: 18)
              ),],
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
          TableRow(decoration: boxDeco,
              children: [Column(
                children: [Text('Earliest notification you would like to receive'
                    , style: TextStyle(color: Colors.white, fontSize: 18)
                ),],
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
          TableRow(decoration: boxDeco,
              children: [Column(
                children: [Text('Latest notification you would like to receive'
                    , style: TextStyle(color: Colors.white, fontSize: 18)
                ),],
              ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
          TableRow(
            children: [
              Column(
                children: [turnOffNotifications()
                ],
              ),
              Column()
            ]
          ),
          TableRow(
              children: [
                Column(
                  children: [ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: areScheduled ? Colors.green : Colors.red, // background
                      onPrimary: Colors.white, // foreground
                    ),
                      onPressed: () async {
                        final bool didUpdate = await staticFunction.scheduleNotifications(endT, startT, numNot, dataBaseKey, context);
                        setState(() {
                          areScheduled = didUpdate;
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
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('currentStudyPackageString');
        await resetSchedule();
        setState(() {
          areScheduled = false;
          prefs.setBool('areScheduled', areScheduled);
          prefs.remove('lastNot_year');
          prefs.remove('lastNot_month');
          prefs.remove('lastNot_day');
          prefs.remove('lastNot_hour');
          prefs.remove('lastNot_min');
        });
      },
      child: Text('Stop Notificaitons'),
    );
  }
}

class staticFunction {
  static Future<bool> scheduleNotifications(int endT, int startT, int numNot, String? dataBaseKey, BuildContext context) async {
    final bool isTimeValid = endT > startT;
    final bool isNumNotValid = numNot > 0;
    bool didUpdate = false;
    if(dataBaseKey == null){
      AlertDialog alert = AlertDialog(
        backgroundColor: Colors.transparent,
        content: Align(child: Text("Error: choose package first", style: TextStyle(color: Colors.white),), alignment: Alignment.center),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 4), () {
            Navigator.of(context).pop(true);
          });
          return alert;
        },
      );
    }
    if(isTimeValid == false){
      AlertDialog alert = AlertDialog(
        backgroundColor: Colors.transparent,
        content: Align(child: Text("Error: end time is before start time", style: TextStyle(color: Colors.white),), alignment: Alignment.center),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 4), () {
            Navigator.of(context).pop(true);
          });
          return alert;
        },
      );
    }
    if (dataBaseKey != null && isNumNotValid && isTimeValid) {  //&& tableNames.contains(currentStudyPackage!)
      List<WordPair> wordPairs = await VocabDatabase.instance.readAllWordPairs(dataBaseKey);

      NotificationApi.init();
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('areScheduled', true);
      didUpdate = true;
      final now = DateTime.now();
      final int numNot_1 = (numNot ==1) ? 1 : numNot-1;
      final double timeDiffMinutes = (endT - startT) * 60 /(numNot_1);
      final int initialNotNr = ((endT - now.hour) * 60 / timeDiffMinutes).toInt();
      double minute = now.minute.toDouble();

      int globalNrNot = 0;
      DateTime endTime = now;
      int addedDay =0;
      for(WordPair curWordPair in wordPairs){
        print('numSeen ' + curWordPair.numberSeen.toString());
        if(curWordPair.numberSeen < curWordPair.maxNumber) {
          for (int i = 0; i < curWordPair.maxNumber; i++) {

            int hour = startT;
            if(globalNrNot < initialNotNr) {
              if(now.hour>=startT) {
                hour = now.hour;  // use the current time for the first notification start
                if (globalNrNot == 0) {
                  minute += 5.0;     // use the default time for the first notification if the startT is in the future
                }
              } else {
                if (globalNrNot == 0) {
                  minute = 0.0;     // use the default time for the first notification if the startT is in the future
                }
              }
            }

            int addedHours   = (minute / 60).toInt();
            if(((addedHours + hour) > endT) ||(((addedHours + hour) == endT) && (numNot == 1))) {
              addedDay = addedDay + 1;
              minute = 0.0;
              addedHours = 0;
            }

            final int addedMinutes = (minute - addedHours * 60).toInt();


            DateTime scheduledTime = DateTime(now.year, now.month, now.day + addedDay, hour + addedHours, addedMinutes, 0);
            endTime = scheduledTime;
            NotificationApi.showScheduledNotification(
              notID: globalNrNot,
              title: curWordPair.baseWord,
              body: curWordPair.translation,
              payload: curWordPair.numberSeen.toString(),
              scheduledTime: scheduledTime,
            );

            print(globalNrNot.toString() + ' ' + scheduledTime.toString());

            minute = minute + timeDiffMinutes;
            curWordPair.iterateNumSeen();

            globalNrNot += 1;
          }
          await VocabDatabase.instance.updateWordPair(curWordPair, dataBaseKey);

          WordPair updatedWP = await VocabDatabase.instance.readWordPair(curWordPair.id!, dataBaseKey);
          print('updatedWP ' + updatedWP.numberSeen.toString());
        }
      }

      prefs.setInt('lastNot_year',  endTime.year);
      prefs.setInt('lastNot_month', endTime.month);
      prefs.setInt('lastNot_day',   endTime.day);
      prefs.setInt('lastNot_hour',  endTime.hour);
      prefs.setInt('lastNot_min',   endTime.minute);
    }
    return didUpdate;
  }
}
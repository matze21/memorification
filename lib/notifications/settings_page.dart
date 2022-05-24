import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/front_page/vocab_packages_front_page.dart';
import '/notifications/notification_api.dart';
import '/database/vocab_database.dart';
import '/database/model.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Page2 extends StatefulWidget {
  const Page2( {Key? key}) : super(key: key);
// todo: add currentStudyPackage to constructor and state, rebuild widget when state changes & therefore update notification schedule

  @override
  _MyPage2State createState() => _MyPage2State();
}

class _MyPage2State extends State<Page2> {
  // Initial Selected Value
  List<int> hours = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
  late int numNot = 1;
  late int startT = 6;
  late int endT = 18;

  @override
  void initState() {
    NotificationApi.init(initScheduled: true);
    updateStoredValues();
    super.initState();
  }

  Future updateStoredValues() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.getInt('numNot') != null) {
      setState(() {
        numNot = prefs.getInt('numNot')!;
      });
    }
    if(prefs.getInt('startT')! != null) {
      setState(() {
        startT = prefs.getInt('startT')!;
      });

    }
    if(prefs.getInt('endT') != null)   {
      setState(() {
        endT = prefs.getInt('endT')!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: new Table(
        columnWidths: {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
        },
        children: [
          TableRow(
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
                items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,15,16,17,18,19,20].map((int value) {
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
          TableRow(
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
                            });
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setInt('startT', startT);
                          }
                      )]
                )
              ]
          ),
          TableRow(
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
                children: [testNotifications()
                ],
              ),
              Column()
            ]
          ),
          TableRow(
              children: [
                Column(
                  children: [ElevatedButton(
                      onPressed: () async { scheduleNotifications(); },
                      child: Text("schedule notifications"),
                  )
                  ],
                ),
                Column()
              ]
          )
        ],
      ))
    );
  }

  Widget testNotifications() {
    return ElevatedButton(
      onPressed: () async {
        if(currentStudyPackage != null && tableNames.contains(currentStudyPackage!)) {
          final int curIdx = currentStudyPackage!.getCurrentId();
          final String key = (currentStudyPackage!).getKey();
          WordPair curWordPair = await VocabDatabase.instance.readWordPair(
              curIdx, (currentStudyPackage!).getKey());

          final now = DateTime.now();
          NotificationApi.showScheduledNotification(
            title: curWordPair.baseWord,
            body: curWordPair.translation,
            payload: curWordPair.numberSeen.toString(),
            scheduledTime: Time(now.hour, now.minute, now.second + 10),
          );
        }
      },
      child: Text('Test' + numNot.toString()),
    );
  }

  Future scheduleNotifications() async {
    if (currentStudyPackage != null && numNot > 0) {  //&& tableNames.contains(currentStudyPackage!)
      final int curIdx = currentStudyPackage!.getCurrentId();
      WordPair curWordPair = await VocabDatabase.instance.readWordPair(
          curIdx, currentStudyPackage!.getKey());
      // get next idx
      // if (curWordPair.numberSeen >= 2) {
      //   List<WordPair> wordPairs = await VocabDatabase.instance
      //       .readAllWordPairs(currentStudyPackage!.getKey());
      //   if (wordPairs.length == curIdx) {
      //     currentStudyPackage!.setCurrentId(1);
      //   }
      //   else {
      //     currentStudyPackage!.setCurrentId(curIdx + 1);
      //   }
      // }

      final now = DateTime.now();
      final double timeDiffMinutes = (endT - startT) * 60 /numNot; // 7:00 - 21:00
      double minute = 0;
      for (int i = 0; i < numNot; i++) {
        final int addedHours = (minute / 60).toInt();
        final int addedMinutes = (minute - addedHours * 60).toInt();

        // get next word pair if more than cur idx
        // if notification - increment key once it's displayed, once you hit the number use next one

        NotificationApi.showScheduledNotification(
          title: curWordPair.baseWord,
          body: curWordPair.translation,
          payload: curWordPair.numberSeen.toString(),
          scheduledTime: Time(startT + addedHours, addedMinutes, 0),
        );
        print('scheduled notification at ' + Time(startT + addedHours, addedMinutes, 0).toString());
        minute = minute + timeDiffMinutes;
        WordPair updatedWordPair = curWordPair.copy(numberSeen: curWordPair.numberSeen + 1);
        VocabDatabase.instance.updateWordPair(updatedWordPair, currentStudyPackage!.getKey());
      }
    }
  }
}
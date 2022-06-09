import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/notifications/notification_api.dart';
import '/database/vocab_database.dart';
import '/database/model.dart';

class staticFunction {
  static Future<bool> scheduleNotificationsPerDay(int endT, int startT, int numNot, String? dataBaseKey, bool isFirstCall) async {
    final bool isTimeValid = endT > startT;
    final bool isNumNotValid = numNot > 0;
    bool didUpdate = false;
    print("scheduled!");
    if (dataBaseKey != null && isNumNotValid && isTimeValid) {
      List<WordPair> wordPairs = await VocabDatabase.instance.readAllWordPairs(dataBaseKey);

      final prefs = await SharedPreferences.getInstance();
      bool? areScheduled = prefs.getBool('areScheduled');

      if((isFirstCall) || ((areScheduled != null) && areScheduled)) {
        NotificationApi.init();

        final now = DateTime.now();
        final int numNot_1 = (numNot == 1) ? 1 : numNot - 1;
        double minute = 0.0;

        int globalNrNot = 0;
        int hour = startT;

        if (isFirstCall) {
          if (now.hour >= startT) { //if startT is already in the past use the current time
            hour = now.hour;
            if (globalNrNot == 0) { //if first call add some minutes
              minute = now.minute.toDouble() + 5.0;
            }
          }
        }
        final double timeDiffMinutes = (hour - startT) * 60 / (numNot_1);

        for (WordPair curWordPair in wordPairs) {
          if (curWordPair.numberSeen < curWordPair.maxNumber) {
            for (int i = 0; i < curWordPair.maxNumber; i++) {
              if (globalNrNot < numNot) {

                if(isFirstCall && now.hour >= endT){
                  break;
                }
                DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute.toInt(), 0);
                NotificationApi.showScheduledNotification(
                  notID: globalNrNot,
                  title: curWordPair.baseWord,
                  body: curWordPair.translation,
                  payload: curWordPair.numberSeen.toString(),
                  scheduledTime: scheduledTime,
                );
                didUpdate = true;
                print(globalNrNot.toString() + ' ' + scheduledTime.toString());

                minute = minute + timeDiffMinutes;
                curWordPair.iterateNumSeen();

                globalNrNot += 1;

                if (globalNrNot == numNot) {
                  await VocabDatabase.instance.updateWordPair(curWordPair, dataBaseKey);
                }
              }
              else {
                break;
              }
            }
          }
        }
        prefs.setBool('areScheduled', didUpdate);
      }
    }
    return didUpdate;
  }
  static Future showErrorMessages(int endT, int startT, int numNot, String? dataBaseKey, BuildContext context) async {
    final bool isTimeValid = endT > startT;
    final bool isNumNotValid = numNot > 0;
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
  }
}
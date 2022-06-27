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
    if (dataBaseKey != null && isNumNotValid && isTimeValid) {
      List<WordPair> wordPairs = await VocabDatabase.instance.readAllWordPairs(dataBaseKey);

      final prefs = await SharedPreferences.getInstance();
      bool? areScheduled = prefs.getBool('areScheduled');

      if((isFirstCall) || ((areScheduled != null) && areScheduled)) {
          NotificationApi.init(initScheduled: true);

        final now = DateTime.now();
        final int numNot_1 = (numNot == 1) ? 1 : numNot - 1;
        double minute = 0.0;

        int globalNrNot = 0;
        int hour = startT;

        if (isFirstCall) {
          if (now.hour >= startT) { //if startT is already in the past use the current time
            hour = now.hour;
            if (globalNrNot == 0) { //if first call add some minutes
              minute = now.minute.toDouble() + 1.0;
            }
          }
        }
        final double timeDiffMinutes = (endT - startT) * 60 / (numNot_1);
        DateTime endTime = DateTime(now.year, now.month, now.day, endT, 0,0);

        for (WordPair curWordPair in wordPairs) {
          if (curWordPair.numberSeen < curWordPair.maxNumber) {
            for (int i = 0; i < curWordPair.maxNumber; i++) {
              if (globalNrNot < numNot) {

                if(isFirstCall && now.hour >= endT){
                  break;
                }
                DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute.toInt(), 0);
                await NotificationApi.showScheduledNotification( //use await??
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

                if(scheduledTime.isAfter(endTime)) {
                  globalNrNot = numNot;
                }

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

  static Future<void> scheduleAllNotifications(int endT, int startT, int numNot, String? dataBaseKey) async {
    final bool isTimeValid = endT > startT;
    final bool isNumNotValid = numNot > 0;

    if (dataBaseKey != null && isNumNotValid && isTimeValid) {
      List<WordPair> wordPairs = await VocabDatabase.instance.readAllWordPairs(dataBaseKey);

      final prefs = await SharedPreferences.getInstance();
      final isSet = prefs.getBool('areScheduled');
      if((isSet == null) ||(isSet != null && !isSet)) {
        NotificationApi.init(initScheduled: true);

        final now = DateTime.now();
        final int numNot_1 = (numNot == 1) ? 1 : numNot - 1;
        double minute = 0.0;
        int day       = now.day;
        if (now.hour >= startT) {
          final addedhour   = now.hour -startT;
          minute = now.minute.toDouble() + 1.0 + addedhour *60;
        }

        final double timeDiffMinutes = (endT - startT) * 60 / (numNot_1);

        int notNr = 0;
        prefs.setInt('endyear', now.year);
        prefs.setInt('endmonth', now.month);
        prefs.setInt('endday', now.day);
        prefs.setInt('starthour', now.hour);
        for (WordPair curWordPair in wordPairs) {
            for (int i = curWordPair.numberSeen; i < curWordPair.maxNumber; i++) {

                DateTime scheduledTime = DateTime(now.year, now.month, day, startT, minute.toInt(), 0);

                if((scheduledTime.hour == endT && scheduledTime.minute > 1) || (scheduledTime.hour > endT)){
                  day = day+1;
                  minute = 0.0;
                }
                scheduledTime = DateTime(now.year, now.month, day, startT, minute.toInt(), 0);

                await NotificationApi.showScheduledNotification(
                  notID: notNr,
                  title: curWordPair.baseWord,
                  body: curWordPair.translation,
                  payload: curWordPair.numberSeen.toString(),
                  scheduledTime: scheduledTime,
                );

                print(notNr.toString() + ' ' + scheduledTime.toString());

                minute = minute + timeDiffMinutes;
                curWordPair.iterateNumSeen();

                notNr += 1;
            }
            await VocabDatabase.instance.updateWordPair(curWordPair, dataBaseKey);
        }
        prefs.setBool('areScheduled', true);
      }
    }
  }

  // check if notifications are already set, if yes update only notifications that are not displayed yet
  static Future<void> updateAllNotifications(int endT, int startT, int numNot, String? dataBaseKey) async {
    final bool isTimeValid = endT > startT;
    final bool isNumNotValid = numNot > 0;

    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getInt('startyear') != null) &&
        (prefs.getInt('startmonth')! != null) &&
        (prefs.getInt('startday') != null) &&
        (prefs.getInt('starthour') != null)) {

      final int startyear = prefs.getInt('startyear')!;
      final int startmonth = prefs.getInt('startmonth')!;
      final int startday = prefs.getInt('startday')!;
      final int starthour = prefs.getInt('starthour')!;
      DateTime startTime = DateTime(startyear, startmonth, startday, starthour, 0, 0);

      if (dataBaseKey != null && isNumNotValid && isTimeValid) {
        List<WordPair> wordPairs = await VocabDatabase.instance
            .readAllWordPairs(dataBaseKey);

        final prefs = await SharedPreferences.getInstance();
        {
          NotificationApi.init(initScheduled: true);

          final now = DateTime.now();
          final int numNot_1 = (numNot == 1) ? 1 : numNot - 1;
          double minute = 0.0;
          int day = startday;
          if (starthour >= startT) {
            final addedhour = starthour - startT;
            minute = now.minute.toDouble() + 1.0 + addedhour * 60;
          }

          final double timeDiffMinutes = (endT - startT) * 60 / (numNot_1);

          int notNr = 0;

          for (WordPair curWordPair in wordPairs) {
            for (int i = 0; i < curWordPair.maxNumber; i++) {
              DateTime scheduledTime = DateTime(startyear, startmonth, day, startT, minute.toInt(), 0);

              if ((scheduledTime.hour == endT && scheduledTime.minute > 1) || (scheduledTime.hour > endT)) {
                day = day + 1;
                minute = 0.0;
              }
              scheduledTime = DateTime(startyear, startmonth, day, startT, minute.toInt(), 0);

              if(scheduledTime.isAfter(now)) {
                await NotificationApi.showScheduledNotification(
                  notID: notNr,
                  title: curWordPair.baseWord,
                  body: curWordPair.translation,
                  payload: curWordPair.numberSeen.toString(),
                  scheduledTime: scheduledTime,
                );

                print(notNr.toString() + ' ' + scheduledTime.toString());

                minute = minute + timeDiffMinutes;
                curWordPair.iterateNumSeen();

                notNr += 1;
              }
            }
            await VocabDatabase.instance.updateWordPair(
                curWordPair, dataBaseKey);
          }
          prefs.setBool('areScheduled', true);
        }
      }
    }
  }
}
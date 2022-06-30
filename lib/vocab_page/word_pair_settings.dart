import 'package:flutter/material.dart';

import '/database/model.dart';
import '/database/vocab_database.dart';
import '/notifications/schedule_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class WordPairSettings extends StatefulWidget {
  const WordPairSettings(this.wordPair, this.databasekey);
  final WordPair wordPair;
  final databaseKey databasekey;

  @override
  _WordPairSettingsState createState() => _WordPairSettingsState();
}

class _WordPairSettingsState extends State<WordPairSettings> {
  late TextEditingController controllerBase;
  late double _value;
  late bool didValueChange = false;

  @override
  void initState() {
    super.initState();
    controllerBase = TextEditingController();
    _value = widget.wordPair.maxNumber.toDouble();
  }

  Future updateSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    bool needToUpdateNotifications =
        (prefs.getString('currentStudyPackageString') != null)
            ? (prefs.getString('currentStudyPackageString') ==
                widget.databasekey.getKey())
            : false;

    if (!Platform.isAndroid && needToUpdateNotifications) {
      print('updating passed notifications');
      // update already seen vocab in order to re-schedule the new notification number
      await staticFunction.updateSeenWordPairs();
    }

    await VocabDatabase.instance
        .updateWordPair(widget.wordPair, widget.databasekey.getKey());

    if (!Platform.isAndroid && needToUpdateNotifications) {
      if ((prefs.getInt('numNot') != null) &&
          (prefs.getInt('startT')! != null) &&
          (prefs.getInt('endT') != null)) {
        final int numNot = prefs.getInt('numNot')!;
        final int startT = prefs.getInt('startT')!;
        final int endT = prefs.getInt('endT')!;
        final String dataBaseKey =
            prefs.getString('currentStudyPackageString')!;

        print('set new notifications');
        // TODO: print message saying that we use the current start & end time / nr Not

        await staticFunction.showErrorMessages(
            endT, startT, numNot, dataBaseKey, context);
        await staticFunction.scheduleAllNotifications(
            endT, startT, numNot, dataBaseKey);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text("Notification Number"),
        content: Table(children: [
          TableRow(
            children: [
              Slider(
                min: 0,
                max: 50,
                value: _value,
                label: '${_value.round()}',
                divisions: 50,
                onChanged: (value) {
                  setState(() {
                    _value = value;
                    didValueChange = true;
                  });
                  widget.wordPair.maxNumber = _value.toInt();
                },
              )
            ],
          ),
          TableRow(
            children: [
              ElevatedButton(
                  child: Text('Study word pair again'),
                  onPressed: () async {
                    widget.wordPair.numberSeen = 0;
                    await updateSchedule();
                  })
            ],
          ),
          TableRow(
            children: [
              ElevatedButton(
                  child: Text('Done Studying word pair'),
                  onPressed: () async {
                    widget.wordPair.numberSeen = widget.wordPair.maxNumber;
                    await updateSchedule();
                  })
            ],
          )
        ]),
        actions: [
          ElevatedButton(
              child: Text('Exit'),
              onPressed: () async {
                Navigator.of(context).pop();
              }),
          ElevatedButton(
              child: Text('Done'),
              onPressed: () async {
                Navigator.of(context).pop();

                if (didValueChange) {
                  await updateSchedule();
                }
              })
        ],
      );
}

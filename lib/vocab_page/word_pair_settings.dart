import 'package:flutter/material.dart';

import '/database/model.dart';
import '/database/vocab_database.dart';
import '/notifications/schedule_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WordPairSettings extends StatefulWidget {
  const WordPairSettings(this.wordPair, this.tableName);
  final WordPair wordPair;
  final databaseKey tableName;

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
    await VocabDatabase.instance.updateWordPair(widget.wordPair, widget.tableName.getKey());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text("Notification Number"),
    content: Table(children: [
      TableRow(children: [
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
      TableRow(children: [
        ElevatedButton(
            child: Text('Study word pair again'),
            onPressed: () async {
              widget.wordPair.numberSeen = 0;
              await updateSchedule();
            }
        )
      ],
      ),
      TableRow(children: [
        ElevatedButton(
            child: Text('Done Studying word pair'),
            onPressed: () async {
              widget.wordPair.numberSeen = widget.wordPair.maxNumber;
              await updateSchedule();
            }
        )
      ],
      )

    ]
    ),
    actions: [
      ElevatedButton(
          child: Text('Done'),
          onPressed: () async {
            Navigator.of(context).pop();

            if(didValueChange) { await updateSchedule(); }
          }
      )
    ],
  );
}
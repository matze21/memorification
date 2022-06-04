import 'package:flutter/material.dart';

import '/database/model.dart';
import '/database/vocab_database.dart';

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

  @override
  void initState() {
    super.initState();
    controllerBase = TextEditingController();
    _value = widget.wordPair.maxNumber.toDouble();
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
          onChanged: (value) async {
            setState(() {
              _value = value;
            });
            widget.wordPair.maxNumber = _value.toInt();
            await VocabDatabase.instance.updateWordPair(widget.wordPair, widget.tableName.getKey());
          },
        )
      ],
      ),
      TableRow(children: [
        ElevatedButton(
            child: Text('Study again'),
            onPressed: () async {
              widget.wordPair.numberSeen = 0;
              await VocabDatabase.instance.updateWordPair(widget.wordPair, widget.tableName.getKey());
            }
        )
      ],
      )
    ]
    ),
    actions: [
      ElevatedButton(
          child: Text('Done'),
          onPressed: () {
            Navigator.of(context).pop();
          }
      )
    ],
  );
}
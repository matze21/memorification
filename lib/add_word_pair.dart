import 'package:flutter/material.dart';

import './model.dart';
import './vocab_database.dart';

class AddWordPairPage extends StatefulWidget {
  const AddWordPairPage(this.tableName);
  final databaseKey tableName;

  @override
  _AddWordPairState createState() => _AddWordPairState();
}

class _AddWordPairState extends State<AddWordPairPage> {
  late TextEditingController controllerBase;
  late TextEditingController controllerTransl;

  @override
  void initState() {
    super.initState();
    controllerBase = TextEditingController(text: widget.tableName.base);
    controllerTransl = TextEditingController(text: widget.tableName.second);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.tableName.getKey()),
    content: Table(children: [
      TableRow(children: [
        TextField(
          controller: controllerBase,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )
      ],
      ),
      TableRow(children: [
        TextField(
          controller: controllerTransl,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )
      ],
      )
    ]
    ),
    actions: [
      ElevatedButton(
          child: Text('Done'),
          onPressed: () {
            WordPair newWordPair = WordPair(baseWord: controllerBase.text, translation: controllerTransl.text, numberSeen: 0);
            VocabDatabase.instance.addWordPair(newWordPair, widget.tableName.getKey());

            Navigator.of(context).pop();
          }
      )
    ],
  );
}
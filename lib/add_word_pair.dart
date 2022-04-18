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
    controllerBase = TextEditingController();
    controllerTransl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.tableName.base + ' ' + widget.tableName.second),
    content: Table(children: [
      TableRow(children: [
        TextField(
          controller: controllerBase..text = widget.tableName.base,
          onTap: () {controllerBase.clear(); },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )
      ],
      ),
      TableRow(children: [
        TextField(
          controller: controllerTransl..text = widget.tableName.second,
          onTap: () {controllerTransl.clear(); },
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
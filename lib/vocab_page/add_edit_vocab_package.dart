import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/database/model.dart';
import '/database/vocab_database.dart';
import 'add_word_pair.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEditPackagePage extends StatefulWidget {
  const AddEditPackagePage(this.tableName);
  final databaseKey tableName;

  @override
  _AddEditPackagePageState createState() => _AddEditPackagePageState();
}

class _AddEditPackagePageState extends State<AddEditPackagePage> {
  late List<WordPair> curWordPairList;
  late List<TableRow> tableRowList;
  final double fontSize = 16;

  bool isLoading = true;

  @override
  void initState() {
    getWordPairs();
    super.initState();

  }

  Future getWordPairs() async {
    setState(() => isLoading = true);
    curWordPairList = await VocabDatabase.instance.readAllWordPairs(widget.tableName.getKey());
    setState(() => updateLocalTable());
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildNewButton()],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : curWordPairList.isEmpty
        ? Center(child: Text(
      'No vocab in this package', style: TextStyle(color: Colors.white, fontSize: 24),
    ))
        : Scrollbar(
        thickness: 10,
        isAlwaysShown: true,
        radius: const Radius.circular(10), // give the thumb rounded corners
        child: ListView.builder(
          itemCount: this.tableRowList.length, // Don't forget this line
          itemBuilder: (context, index) => Table(
              border: TableBorder.all(),
              key: ValueKey(this.tableRowList[index]),
              columnWidths: {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(1),
              },
              children: [this.tableRowList[index]],
          ),
        ),
        )
        //child:
        //border: TableBorder.all(), children: this.tableRowList)),
  );

  void updateLocalTable() {
    setState(() {
      this.tableRowList = [
        TableRow(children: [
          Column(children: [
            Text('ID', style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ))
          ]),
          Column(children: [
            Text(widget.tableName.base, style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ))
          ]),
          Column(children: [
            Text(widget.tableName.second, style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ))
          ]),
          Column(children: [
            Text(' ', style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ))
          ]),
        ])
      ];

      if(curWordPairList.isNotEmpty) {
        for (WordPair wordPair in curWordPairList) {
          this.tableRowList.add(
              TableRow(children: [
                Center(child: Text(wordPair.id.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold,))),
                TextField(
                  controller: TextEditingController()..text = wordPair.baseWord,
                  style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold,),
                  onSubmitted: (value) {
                    wordPair.updateBase(value);
                    VocabDatabase.instance.updateWordPair(wordPair, widget.tableName.getKey());
                  },
                ),
                TextField(
                  controller: TextEditingController()..text = wordPair.translation,
                  style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold,),
                  onSubmitted: (value) {
                    wordPair.updateTranslation(value);
                    VocabDatabase.instance.updateWordPair(wordPair, widget.tableName.getKey());
                  },
                ),
                Center(child: deleteButton(wordPair.id!)),
              ])
          );
        }
      }
    });
  }

  Widget buildNewButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: Colors.grey.shade700,
        ),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddWordPairPage(widget.tableName)),);
          await getWordPairs();
        },
        child: Text('Add Pair'),
      ),
    );
  }

  Widget deleteButton(int id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.grey.shade700,
      ),
      onPressed: () async {
        final prefs            = await SharedPreferences.getInstance();
        final String curString = prefs.getString('currentStudyPackageString')!;
          if(curString != null) // && curString == id)
          {
            prefs.remove('currentStudyPackageString');
          }
          await VocabDatabase.instance.deleteWordPair(id, widget.tableName.getKey());
          await getWordPairs();
        },
        child: Icon(
          Icons.delete,
          size: 20.0,
        ),
      );
  }
}


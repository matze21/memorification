import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/database/model.dart';
import '/database/vocab_database.dart';
import 'add_word_pair.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'word_pair_settings.dart';

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
    curWordPairList = await VocabDatabase.instance
        .readAllWordPairs(widget.tableName.getKey());
    updateLocalTable();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        actions: [buildNewButton(), studyAgainButton()],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : curWordPairList.isEmpty
              ? Center(
                  child: Text(
                  'No vocab in this package',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ))
              : Scrollbar(
                  interactive: true,
                  child: ListView.builder(
                    itemCount:
                        this.tableRowList.length, // Don't forget this line
                    itemBuilder: (context, index) => Table(
                      key: ValueKey(this.tableRowList[index]),
                      columnWidths: {
                        0: FlexColumnWidth(0.95),
                        1: FlexColumnWidth(3),
                        2: FlexColumnWidth(0.1),
                        3: FlexColumnWidth(3),
                        4: FlexColumnWidth(0.95),
                      },
                      children: [this.tableRowList[index]],
                    ),
                    scrollDirection: Axis.vertical,
                  ),
                ));

  void updateLocalTable() {
    this.tableRowList = [
      TableRow(children: [
        Column(children: []),
        Column(children: [
          Align(
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(widget.tableName.base,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            alignment: Alignment.centerLeft,
          )
        ]),
        Column(children: []),
        Column(children: [
          Align(
            child: FittedBox(
                fit: BoxFit.contain,
                child: Text(widget.tableName.second,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            alignment: Alignment.centerLeft,
          )
        ]),
        Column(children: []),
      ])
    ];

    if (curWordPairList.isNotEmpty) {
      for (WordPair wordPair in curWordPairList) {
        this.tableRowList.add(TableRow(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      //offset: const Offset(5.0, 5.0,), //Offset
                      blurRadius: 1.0,
                      spreadRadius: 2.0,
                    )
                  ], //BoxShadow
                ),
                children: [
                  Container(child: settingsButton(wordPair)),
                  TextField(
                    controller: TextEditingController()
                      ..text = wordPair.baseWord,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    onSubmitted: (value) {
                      wordPair.updateBase(value);
                      VocabDatabase.instance
                          .updateWordPair(wordPair, widget.tableName.getKey());
                    },
                  ),
                  Column(children: []),
                  TextField(
                    controller: TextEditingController()
                      ..text = wordPair.translation,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    onSubmitted: (value) {
                      wordPair.updateTranslation(value);
                      VocabDatabase.instance
                          .updateWordPair(wordPair, widget.tableName.getKey());
                    },
                  ),
                  Center(child: deleteButton(wordPair.id!)),
                ]));
      }
    }
    ;
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
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddWordPairPage(widget.tableName)),
          );
          await getWordPairs();
        },
        child: Text('Add Pair'),
      ),
    );
  }

  Widget studyAgainButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: Colors.grey.shade700,
        ),
        onPressed: () async {
          for (WordPair wp in curWordPairList) {
            wp.numberSeen = 0;
            await VocabDatabase.instance
                .updateWordPair(wp, widget.tableName.getKey());
          }
        },
        child: Text('Study all again'),
      ),
    );
  }

  Widget deleteButton(int id) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.transparent,
        elevation: 0.0,
        shadowColor: Colors.transparent,
        minimumSize: Size.zero, // Set this
        padding: EdgeInsets.zero, // and this
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        final String? curString = prefs.getString('currentStudyPackageString');
        if (curString != null) // && curString == id)
        {
          prefs.remove('currentStudyPackageString');
        }
        await VocabDatabase.instance
            .deleteWordPair(id, widget.tableName.getKey());
        await getWordPairs();
      },
      child: Icon(
        Icons.delete,
      ),
    );
  }

  Widget settingsButton(WordPair wordPair) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.transparent,
        elevation: 0.0,
        shadowColor: Colors.transparent,
        minimumSize: Size.zero, // Set this
        padding: EdgeInsets.zero, // and this
      ),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) =>
                  WordPairSettings(wordPair, widget.tableName)),
        );
      },
      child: Icon(
        Icons.settings,
      ),
    );
  }
}

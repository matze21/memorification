import 'package:flutter/material.dart';

import './model.dart';
import './vocab_database.dart';
import './add_word_pair.dart';

class AddEditPackagePage extends StatefulWidget {
  const AddEditPackagePage(this.tableName);
  final databaseKey tableName;

  @override
  _AddEditPackagePageState createState() => _AddEditPackagePageState();
}

class _AddEditPackagePageState extends State<AddEditPackagePage> {
  late List<WordPair> curWordPairList;
  late List<TableRow> tableRowList;

  @override
  void initState() {
    super.initState();
    curWordPairList = [];
    tableRowList = [];
    getWordPairs();
  }

  Future getWordPairs() async {
      curWordPairList = await VocabDatabase.instance.readAllWordPairs(
          widget.tableName.getKey());

      tableRowList = [
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
        ])
      ];
      for (WordPair wordPair in curWordPairList) {
        tableRowList.add(
            TableRow(children: [
              Center(child: Text(wordPair.id.toString(), style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ))),
              Center(child: Text(wordPair.baseWord, style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ))),
              Center(child: Text(wordPair.translation, style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ))),
            ])
        );
      }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildNewButton()],
    ),
    body: Table(border: TableBorder.all(), children: tableRowList),
    /*body: Editable(
      columns: ['fist','second','# seen'],
      rows: curWordPairList,
      showCreateButton: true,
      tdStyle: TextStyle(fontSize: 20),
      showSaveIcon: false,
      borderColor: Colors.grey.shade300,
      onSubmitted: (value){ //new line
        //print(value); //you can grab this data to store anywhere
      },
    ),*/
  );


  Widget buildNewButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: Colors.grey.shade700,
        ),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddWordPairPage(widget.tableName)),);
          getWordPairs();
        },
        child: Text('Add Pair'),
      ),
    );
  }
}


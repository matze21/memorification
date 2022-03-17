import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './notes_database.dart';
import './model.dart';
import './edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late List<WordPair> wordPairs;
  late List<TableRow> tableRowList;
  bool isLoading = false;
  double iconSize = 40;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    wordPairs = await NotesDatabase.instance.readAllWordPairs();

    tableRowList = [
      TableRow( children: [
        Column(children:[
          Text('ID', style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ))
        ]),
        Column(children:[
          Text('English', style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ))
        ]),
        Column(children:[
          Text('Spanish', style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ))
        ]),
      ])
    ];
    for(WordPair wordPair in wordPairs)
    {
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

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
      padding: EdgeInsets.all(12),
      child: Table(border: TableBorder.all(), children: tableRowList),
      )
    );



  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(wordPairList: wordPairs),
        ));

        refreshNote();
      });

  Widget deleteButton() => IconButton(
    icon: Icon(Icons.delete),
    onPressed: () async {
      await NotesDatabase.instance.deleteWordPair(widget.noteId);

      Navigator.of(context).pop();
    },
  );
}
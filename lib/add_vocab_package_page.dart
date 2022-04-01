import 'package:flutter/material.dart';
import './vocab_database.dart';
import './model.dart';
import './add_edit_vocab_package.dart';

class AddVocabPackagePage extends StatefulWidget {

  const AddVocabPackagePage({
    Key? key,
  }) : super(key: key);
  @override
  _AddVocabPackagePageState createState() => _AddVocabPackagePageState();
}

class _AddVocabPackagePageState extends State<AddVocabPackagePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController controllerFirst;
  late TextEditingController controllerSecond;

  @override
  void initState() {
    super.initState();

    controllerFirst = TextEditingController(text: 'first');
    controllerSecond = TextEditingController(text: 'second');
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Enter two languages'),
    content: Table(children: [
      TableRow(children: [
        TextField(
          controller: controllerFirst,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )],
       ),
      TableRow(children: [
        TextField(
          controller: controllerSecond,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )],
      )]
    ),
    actions: [
      ElevatedButton(
        child: Text('Done'),
        onPressed: ()  {
          final databaseKey curTableName = addDatabaseTable(controllerFirst.text, controllerSecond.text);
          Navigator.of(context).pop();

          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddEditPackagePage(curTableName)),
          );


        }
      )
    ],
  );
}

databaseKey addDatabaseTable(String firstLanguage, String secondLanguage)
{
  databaseKey key = databaseKey(base: firstLanguage, second: secondLanguage, curIndex: 1);
  tableNames.add(key);
  VocabDatabase.createDB(key.getKey());

  return key;
}
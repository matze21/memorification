import 'package:flutter/material.dart';
import '/database/vocab_database.dart';
import '/database/model.dart';
import 'add_edit_vocab_package.dart';

class AddVocabPackagePage extends StatefulWidget {

  const AddVocabPackagePage({
    Key? key,
  }) : super(key: key);
  @override
  _AddVocabPackagePageState createState() => _AddVocabPackagePageState();
}

class _AddVocabPackagePageState extends State<AddVocabPackagePage> {
  final _formKey = GlobalKey<FormState>();
  final String addString = 'additional description';

  late TextEditingController controllerFirst;
  late TextEditingController controllerSecond;
  late TextEditingController controllerAdd;

  @override
  void initState() {
    super.initState();

    controllerFirst = TextEditingController();
    controllerSecond = TextEditingController();
    controllerAdd = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Enter two languages'),
    content: Table(children: [
      TableRow(children: [
        TextField(
          controller: controllerFirst..text = 'first',
          onTap: () {controllerFirst.clear(); },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )],
       ),
      TableRow(children: [
        TextField(
          controller: controllerSecond..text = 'second',
          onTap: () {controllerSecond.clear(); },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        )],
      ),
      TableRow(children: [
        TextField(
          controller: controllerAdd..text = addString,
          onTap: () {controllerAdd.clear(); },
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
          if(controllerAdd.text != addString){
            final databaseKey curTableName = addDatabaseTable(controllerFirst.text, controllerSecond.text, controllerAdd.text);
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditPackagePage(curTableName)),);
          } else {
            final databaseKey curTableName = addDatabaseTable(controllerFirst.text, controllerSecond.text, null);
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditPackagePage(curTableName)),);
          }
        }
      )
    ],
  );
}

databaseKey addDatabaseTable(String firstLanguage, String secondLanguage, String? add)
{
  databaseKey key = databaseKey(base: firstLanguage, second: secondLanguage, addition: add);
  VocabDatabase.createDB(key.getKey());

  return key;
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/database/vocab_database.dart';
import '/database/model.dart';
import '/vocab_page//add_edit_vocab_package.dart';
import '/vocab_page/add_vocab_package_page.dart';


class vocabPackagesPage extends StatefulWidget {
  const vocabPackagesPage({Key? key}) : super(key: key);
  @override
  _vocabPackagesPageState createState() => _vocabPackagesPageState();
}

class _vocabPackagesPageState extends State<vocabPackagesPage> {
  bool isLoading = false;
  bool isPackageExisting = false;
  int notificationNr = 0;
  databaseKey? currentStudyPackage = null;
  List<databaseKey> tableNames = [];

  @override
  void initState() {
    super.initState();
    refreshVocabPackages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future refreshVocabPackages() async {
    setState(() => isLoading = true);

    List<databaseKey> tableNamesCopy = await VocabDatabase.instance.getAllExistingDataTables();
    setState(() { tableNames = tableNamesCopy; });

    if(tableNames.isNotEmpty) {
        setState(() => isPackageExisting = true);
    }

    final prefs = await SharedPreferences.getInstance();
    currentStudyPackage = null;
    if(prefs.getString('currentStudyPackageString') != null) {
      final String curString = prefs.getString('currentStudyPackageString')!;
      currentStudyPackage = databaseKey.getDataBaseKeyFromKey(curString);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Table(children:
        [TableRow(
          children: [Text('Vocab Packages',
            style: TextStyle(fontSize: 24),)],
          ),
        TableRow(
          children: [Container(width: 200, child: Text(
              (currentStudyPackage == null)
                  ? 'No package selected'
                  : 'Studying: ' + currentStudyPackage!.base +' ' + currentStudyPackage!.second
              , style: TextStyle(color: Colors.white, fontSize: 18)
          ),)],),
        ]
      ),
      actions: [findAllButton()] //, Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? CircularProgressIndicator()
          : tableNames.isEmpty
          ? Text(
        'No Packages loaded',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : renderPackages(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => AddVocabPackagePage()),
        );

        await refreshVocabPackages();
      },
    ),
  );

  Widget findAllButton() {
    return ElevatedButton(
      onPressed: () async {
        await VocabDatabase.instance.getAllExistingDataTables();
        await refreshVocabPackages();
      },
      child: Icon(Icons.search, size: 20.0,),
    );
  }



  Widget selectStudyPackage(databaseKey key) {
    return ElevatedButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('currentStudyPackageString', key.getKey());
        refreshVocabPackages();
      },
      child: Text('study package'),
    );
  }

  Widget renderPackages() => StaggeredGridView.countBuilder(
    padding: EdgeInsets.all(8),
    itemCount: tableNames.length,
    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    crossAxisCount: 4,
    mainAxisSpacing: 4,
    crossAxisSpacing: 4,
    itemBuilder: (context, index) {
      final databaseKey package = tableNames[index];

      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddEditPackagePage(package),
          ));

          await refreshVocabPackages();
        },
        child: NoteCardWidget(package, index),
      );
    },
  );

  Widget NoteCardWidget(databaseKey vocabPackage, int index){
    final _lightColors = [Colors.amber.shade300, Colors.lightGreen.shade300, Colors.lightBlue.shade300, Colors.orange.shade300, Colors.pinkAccent.shade100, Colors.tealAccent.shade100];

    /// Pick colors from the accent colors based on index
    final color = _lightColors[index % _lightColors.length];
    final minHeight = getMinHeight(index);

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              vocabPackage.base + ' ' + vocabPackage.second,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                tableNames.remove(vocabPackage); //only removes from visu
                await VocabDatabase.instance.deleteDB(vocabPackage.getKey());
                final prefs = await SharedPreferences.getInstance();
                if((currentStudyPackage != null) && (vocabPackage.getKey() == currentStudyPackage!.getKey())) { //reset the pointer to the study package if we delete the current one
                    currentStudyPackage = null;
                    prefs.remove('currentStudyPackageString');
                }
                await refreshVocabPackages();
              },
              child: Icon(Icons.delete, size: 20.0,),
            ),
            selectStudyPackage(vocabPackage)
          ],
        ),
      ),
    );
  }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }
}
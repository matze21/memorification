import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import './vocab_database.dart';
import './model.dart';
import './add_edit_vocab_package.dart';
import './add_vocab_package_page.dart';
import './notification_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class vocabPackagesPage extends StatefulWidget {
  const vocabPackagesPage({Key? key}) : super(key: key);
  @override
  _vocabPackagesPageState createState() => _vocabPackagesPageState();
}

class _vocabPackagesPageState extends State<vocabPackagesPage> {
  bool isLoading = false;
  bool isPackageExisting = false;
  int notificationNr = 0;

  @override
  void initState() {
    super.initState();
    //tableNames = [];  // add predefined libraries?
    NotificationApi.init(initScheduled: true);
    refreshVocabPackages();
  }

  @override
  void dispose() {
    VocabDatabase.instance.close();

    super.dispose();
  }

  Future refreshVocabPackages() async {
    setState(() => isLoading = true);

    await VocabDatabase.initInstance();

    if(tableNames.isNotEmpty)
      {
        setState(() => isPackageExisting = true);
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
                  ? 'No package selected for studying'
                  : 'Studying: ' + currentStudyPackage!.getKey()
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

        refreshVocabPackages();
      },
    ),
  );

  Widget findAllButton() {
    return ElevatedButton(
      onPressed: () async {
        tableNames = await VocabDatabase.instance.getAllExistingDataTables();
        refreshVocabPackages();
      },
      child: Icon(Icons.search, size: 20.0,),
    );
  }

  Widget selectStudyPackage(databaseKey key) {
    return ElevatedButton(
      onPressed: () async {
        currentStudyPackage = key;
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

          refreshVocabPackages();
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
              vocabPackage.getKey(),
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
                refreshVocabPackages();
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
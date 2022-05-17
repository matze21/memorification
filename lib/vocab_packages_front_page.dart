import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import './vocab_database.dart';
import './model.dart';
import './add_edit_vocab_package.dart';
import './add_vocab_package_page.dart';
import './notification_api.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'settings_page.dart';


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
    super.dispose();
  }

  Future refreshVocabPackages() async {
    setState(() => isLoading = true);

    await VocabDatabase.instance.getAllExistingDataTables();
    await scheduleNotifications();
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
      actions: [testNotifications(), findAllButton()] //, Icon(Icons.search), SizedBox(width: 12)],
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
        await VocabDatabase.instance.getAllExistingDataTables();
        refreshVocabPackages();
      },
      child: Icon(Icons.search, size: 20.0,),
    );
  }

  Widget testNotifications() {
    return ElevatedButton(
      onPressed: () async {
        if(currentStudyPackage != null && tableNames.contains(currentStudyPackage!)) {
          final int curIdx = currentStudyPackage!.getCurrentId();
          final String key = (currentStudyPackage!).getKey();
          WordPair curWordPair = await VocabDatabase.instance.readWordPair(
               curIdx, (currentStudyPackage!).getKey());
          // get next idx
          if (curWordPair.numberSeen >= 2) {
            List<WordPair> wordPairs = await VocabDatabase.instance
                .readAllWordPairs(currentStudyPackage!.getKey());
            if (wordPairs.length == curIdx) {
              currentStudyPackage!.setCurrentId(1);
            }
            else {
              currentStudyPackage!.setCurrentId(curIdx + 1);
            }
          }

          final now = DateTime.now();
          NotificationApi.showScheduledNotification(
            title: curWordPair.baseWord,
            body: curWordPair.translation,
            payload: curWordPair.numberSeen.toString(),
            scheduledTime: Time(now.hour, now.minute, now.second + 10),
          );
        }
      },
      child: Text('Test' + snotificationNr.toString()),
    );
  }

  Future scheduleNotifications() async {
    if (currentStudyPackage != null && snotificationNr > 0 && tableNames.contains(currentStudyPackage!)) {
      final int curIdx = currentStudyPackage!.getCurrentId();
      WordPair curWordPair = await VocabDatabase.instance.readWordPair(
          curIdx, currentStudyPackage!.getKey());
      // get next idx
      if (curWordPair.numberSeen >= 2) {
        List<WordPair> wordPairs = await VocabDatabase.instance
            .readAllWordPairs(currentStudyPackage!.getKey());
        if (wordPairs.length == curIdx) {
          currentStudyPackage!.setCurrentId(1);
        }
        else {
          currentStudyPackage!.setCurrentId(curIdx + 1);
        }
      }

      final now = DateTime.now();
      final double timeDiffMinutes = (sendTime - sstartTime) * 60 /
          snotificationNr; // 7:00 - 21:00
      double minute = 0;
      for (int i = 0; i < snotificationNr; i++) {
        final int addedHours = (minute / 60).toInt();
        final int addedMinutes = (minute - addedHours * 60).toInt();
        NotificationApi.showScheduledNotification(
          title: curWordPair.baseWord,
          body: curWordPair.translation,
          payload: curWordPair.numberSeen.toString(),
          scheduledTime: Time(Page2.getStartTime() + addedHours, addedMinutes, 0),
        );
        minute = minute + timeDiffMinutes;
        WordPair updatedWordPair = curWordPair.copy(numberSeen: curWordPair.numberSeen + 1);
        VocabDatabase.instance.updateWordPair(updatedWordPair, currentStudyPackage!.getKey());
      }
    }
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
                if((currentStudyPackage != null) && (vocabPackage.getCurrentId() == currentStudyPackage!.getCurrentId())) { //reset the pointer to the study package if we delete the current one
                    currentStudyPackage = null;
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
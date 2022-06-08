import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'front_page/home_page.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications/schedule_notifications.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print("periodic task");
    final prefs = await SharedPreferences.getInstance();
    if((prefs.getInt('numNot') != null) && (prefs.getInt('startT')! != null) && (prefs.getInt('endT') != null) && (prefs.getString('currentStudyPackageString') != null)) {
      int numNot = prefs.getInt('numNot')!;
      int startT = prefs.getInt('startT')!;
      int endT = prefs.getInt('endT')!;
      String dataBaseKey = prefs.getString('currentStudyPackageString')!;
      bool didUpdate = await staticFunction.scheduleNotificationsPerDay(endT, startT, numNot, dataBaseKey, false);
    }
    Workmanager().registerOneOffTask(
        "dailyNotificationSchedule",
        "backUp",
        initialDelay: Duration(days: 1),
        existingWorkPolicy: ExistingWorkPolicy.append
    );
    return Future.value(true);
  });
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Workmanager().registerPeriodicTask(
  //   "dailyNotificationSchedule",
  //   "backUp",
  //   frequency: Duration(minutes: 1),
  // );

  Workmanager().registerOneOffTask(
      "dailyNotificationSchedule",
      "backUp",
      //initialDelay: Duration(minutes: 1),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String title = 'Memorification';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    themeMode: ThemeMode.dark,
    theme: ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.blueGrey.shade900,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    ),
    home: HomePage(),
  );
}
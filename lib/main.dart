import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'front_page/home_page.dart';

import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notifications/schedule_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/notifications/notification_api.dart';
import 'dart:io' show Platform;

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await NotificationApi.cancel();

    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getInt('numNot') != null) &&
        (prefs.getInt('startT')! != null) &&
        (prefs.getInt('endT') != null) &&
        (prefs.getString('currentStudyPackageString') != null)) {
      final int numNot = prefs.getInt('numNot')!;
      final int startT = prefs.getInt('startT')!;
      final int endT = prefs.getInt('endT')!;
      final String dataBaseKey = prefs.getString('currentStudyPackageString')!;

      bool didUpdate = await staticFunction.scheduleNotificationsPerDay(
          endT, startT, numNot, dataBaseKey, false);
      print('did update' + didUpdate.toString());
    }

    final now = DateTime.now();
    print("periodic task next in" + (24 - now.hour).toString());
    Workmanager().registerOneOffTask("dailyNotificationSchedule", "backUp",
        initialDelay: Duration(minutes: 2), //hours: 24 - now.hour),
        existingWorkPolicy: ExistingWorkPolicy.append);
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // use workmanager on android and schedule all notifications at once for ios
  //if(Platform.isAndroid) {
  await Workmanager().initialize(
    callbackDispatcher,
    //isInDebugMode: true,
  );
  await Workmanager().registerOneOffTask(
    "dailyNotificationSchedule",
    "backUp",
  );
  //}

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

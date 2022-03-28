import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// helpful widget: SnackBar(content: Text('')) -> shows bottom notification


/*class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    NotificationApi.init(true); // init scheduled notifications
    listenNotifications();
  }

  void listenNotifications() =>
      NotificationApi.onNotifications.stream.listen(onClickedNotification);

  // decide what to do when notification is clicked!!
  void onClickedNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SecondPage(payload: payload),
      ));

   // add scheduled notification
   NotificationApi.showScheduledNotification(
      title: '',
      body: '',
      payload: '',
      scheduledDate: DateTime.now().add(Duration(seconds:12)),  //can switch it up to any time
      );

  @override
  Widget build(BuildContext context) => Scaffold();
}*/

class NotificationApi {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          channelDescription: 'channel description',
          importance: Importance.max,
        ),
        iOS: IOSNotificationDetails(),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
}) async => _notifications.show(
    id, title, body, await _notificationDetails(), payload: payload,
  );

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    //required DateTime scheduleDate,
    required Time scheduledTime, // e.g. Time(8) = 8 am
  }) async => _notifications.zonedSchedule(
    id, title, body,
    _scheduleDaily(scheduledTime),  //tz.TZDateTime.from(scheduleDate, tz.local),
    await _notificationDetails(), payload: payload,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );

  static tz.TZDateTime _scheduleDaily(Time time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute, time.second);

    return scheduledDate.isBefore(now)
        ? scheduledDate.add(Duration(days: 1))
        : scheduledDate;
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(settings,
      onSelectNotification: (payload) async {
        onNotifications.add(payload);
      },
    );

    if(initScheduled) {
      tz.initializeTimeZones();
      final locationName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(locationName));
    }
  }
}
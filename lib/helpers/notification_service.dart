import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';


class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/ic_stat_notifications');

    // Need to add more to properly make iOS notifications work
    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: null
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future selectNotification(String payload) async {
    //Handle notification tapped logic here
  }

  void showSanitaryChangeReminder(String sanitaryItem) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('tyd-timer', 'Tampon timer',
        channelDescription: 'Tampon Timer',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'It\'s time!', 'Time to change your ${sanitaryItem.toLowerCase()}.', platformChannelSpecifics,
        payload: 'item x');
  }

  void showTimedSanitaryChangeReminder(String sanitaryItem, DateTime showTime) async {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    // print('Logged for: ${tz.TZDateTime.from(showTime, tz.local)}');

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'It\'s time!',
        'Time to change your ${sanitaryItem.toLowerCase()}.',
        tz.TZDateTime.from(showTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'tyd-timer', 'Tampon timer',
                channelDescription: 'Tampon Timer',
                importance: Importance.max,
                priority: Priority.max,
                ticker: 'Time to change!',
            ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void cancelPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
    await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var pendingRequest in pendingNotificationRequests) {
      flutterLocalNotificationsPlugin.cancel(pendingRequest.id);
    }
  }

}
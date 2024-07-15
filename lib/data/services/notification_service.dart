import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launch_background');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification(
      int id, String title, String body, DateTime scheduledDate) async {
    debugPrint('schedule notify with ID:$id');
    debugPrint('schedule time : $scheduledDate');
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
          scheduledDate, tz.local), // Chuyển đổi DateTime thành TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'my_app_notification_channel', // channel ID
          'my notify app', // chanel name
          channelDescription: 'notify event and update',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelNotification(int id) async {
    // cancel notify
    await _notificationsPlugin.cancel(id);
  }
}

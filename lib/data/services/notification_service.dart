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
    print('Lên lịch thông báo với ID:$id');
    print('Thời gian lên lịch: $scheduledDate');
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
          scheduledDate, tz.local), // Chuyển đổi DateTime thành TZDateTime
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'my_app_notification_channel', // ID kênh
          'Thông báo ứng dụngcủa tôi', // Tên kênh
          channelDescription:
              'Thông báo về các sự kiện và cập nhật quan trọng', //
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
    // Hủy thông báo
    await _notificationsPlugin.cancel(id);
  }
}

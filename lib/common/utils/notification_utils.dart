import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future setupNotifications({
  DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
  SelectNotificationCallback onSelectNotification,
}) async {
  const initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification');
  final initializationSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
    onDidReceiveLocalNotification: onIosReceiveLocalNotification,
  );
  final initializationSettings = InitializationSettings(
    initializationSettingsAndroid,
    initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: onSelectNotification,
  );
}

Future<bool> requestIOSPermissions() async {
  final result = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  if (result == null) return false;

  return result;
}

Future<void> showNotification(
  String title,
  String body, {
  int id = 0,
  String payload,
}) async {
  const channel = 'my_expenses_channel';
  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channel,
    'Notifications',
    'Notifications from the app',
    importance: Importance.Max,
    priority: Priority.High,
    ticker: 'ticker',
    autoCancel: true,
    enableLights: true,
    enableVibration: true,
    color: Colors.red,
    style: AndroidNotificationStyle.BigText,
    largeIcon: 'cost',
    largeIconBitmapSource: BitmapSource.Drawable,
  );
  final iOSPlatformChannelSpecifics = IOSNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    androidPlatformChannelSpecifics,
    iOSPlatformChannelSpecifics,
  );
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
}

Future<void> cancelNotification(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

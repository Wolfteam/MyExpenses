import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const _channelId = 'my_expenses_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'cost';

const _androidPlatformChannelSpecifics = AndroidNotificationDetails(
  _channelId,
  _channelName,
  _channelDescription,
  importance: Importance.Max,
  priority: Priority.High,
  enableLights: true,
  color: Colors.red,
  largeIcon: DrawableResourceAndroidBitmap(_largeIcon),
);

const _iOSPlatformChannelSpecifics = IOSNotificationDetails();

const _platformChannelSpecifics = NotificationDetails(
  _androidPlatformChannelSpecifics,
  _iOSPlatformChannelSpecifics,
);

Future setupNotifications({
  DidReceiveLocalNotificationCallback onIosReceiveLocalNotification,
  SelectNotificationCallback onSelectNotification,
}) async {
  const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
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
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: onSelectNotification,
  );
}

Future<bool> requestIOSPermissions() async {
  final result = await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
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
  String body,
  String payload, {
  int id = 0,
}) {
  if (body.length > 40) {
    final androidPlatformChannelSpecificsBigStyle = AndroidNotificationDetails(
      _channelId,
      _channelName,
      _channelDescription,
      importance: Importance.Max,
      priority: Priority.High,
      enableLights: true,
      color: Colors.red,
      styleInformation: BigTextStyleInformation(body),
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
    );

    final _platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecificsBigStyle,
      _iOSPlatformChannelSpecifics,
    );

    return _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _platformChannelSpecifics,
      payload: payload,
    );
  }
  return _flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    _platformChannelSpecifics,
    payload: payload,
  );
}

Future<void> cancelNotification(int id) {
  return _flutterLocalNotificationsPlugin.cancel(id);
}

Future<void> cancelAllNotifications() {
  return _flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> scheduleNotification(
  int id,
  String title,
  String body,
  DateTime deliveredOn,
) {
  return _flutterLocalNotificationsPlugin.schedule(
    id,
    title,
    body,
    deliveredOn,
    _platformChannelSpecifics,
    androidAllowWhileIdle: true,
  );
}

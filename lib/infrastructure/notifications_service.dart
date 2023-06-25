import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const _channelId = 'my_expenses_channel';
const _channelName = 'Notifications';
const _channelDescription = 'Notifications from the app';
const _largeIcon = 'cost';

//Here we use this one in particular cause this tz uses UTC and does not use any kind of dst.
const _fallbackTimeZone = 'Africa/Accra';

class NotificationServiceImpl implements NotificationService {
  final LoggingService _loggingService;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final StreamController<AppNotification> _selectNotificationStream = StreamController<AppNotification>.broadcast();

  late tz.Location _location;

  @override
  StreamController<AppNotification> get selectNotificationStream => _selectNotificationStream;

  NotificationServiceImpl(this._loggingService);

  @override
  Future<void> init() async {
    try {
      //TODO: TIMEZONES ON WINDOWS
      if (Platform.isWindows) {
        return;
      }
      tz.initializeTimeZones();
      final currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
      _location = tz.getLocation(currentTimeZone);
      tz.setLocalLocation(_location);
    } on tz.LocationNotFoundException catch (e) {
      //https://github.com/srawlins/timezone/issues/92
      _loggingService.info(runtimeType, 'init: ${e.msg}, assigning the generic one...');
      _setDefaultTimeZone();
    } catch (e, s) {
      _loggingService.error(runtimeType, 'init: Failed to get timezone or device is GMT or UTC, assigning the generic one...', e, s);
      _setDefaultTimeZone();
    }
  }

  @override
  Future<void> dispose() async {
    await selectNotificationStream.close();
  }

  @override
  Future<void> registerCallBacks() async {
    try {
      if (Platform.isWindows) {
        return Future.value();
      }
      const initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');
      final initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
          // didReceiveLocalNotificationStream.add(
          //   ReceivedNotification(
          //     id: id,
          //     title: title,
          //     body: body,
          //     payload: payload,
          //   ),
          // );
        },
      );
      final initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          if (notificationResponse.payload.isNullEmptyOrWhitespace) {
            return;
          }

          final notification = AppNotification.fromJson(jsonDecode(notificationResponse.payload!) as Map<String, dynamic>);
          switch (notificationResponse.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              selectNotificationStream.add(notification);
              break;
            default:
              break;
          }
        },
      );
    } catch (e, s) {
      _loggingService.error(runtimeType, 'registerCallBacks: Unknown error occurred', e, s);
    }
  }

  @override
  Future<bool> requestIOSPermissions() async {
    final specificImpl = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final result = await specificImpl?.requestPermissions(alert: true, badge: true, sound: true);

    if (result == null) {
      return false;
    }

    return result;
  }

  @override
  Future<void> showNotificationWithoutId(AppNotificationType type, String title, String body, {String? payload}) {
    final id = DateTime.now().millisecond;
    return showNotification(id, type, title, body, payload: payload);
  }

  @override
  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload}) {
    if (Platform.isWindows) {
      return Future.value();
    }
    final specifics = _getPlatformChannelSpecifics(type, body);
    final newId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.show(newId, title, body, specifics, payload: payload);
  }

  @override
  Future<void> cancelNotification(int id, AppNotificationType type) {
    if (Platform.isWindows) {
      return Future.value();
    }
    final realId = _generateUniqueId(id, type);
    return _flutterLocalNotificationsPlugin.cancel(realId, tag: _getTagFromNotificationType(type));
  }

  @override
  Future<void> cancelAllNotifications() {
    if (Platform.isWindows) {
      return Future.value();
    }
    return _flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn) async {
    if (Platform.isWindows) {
      return;
    }
    final now = DateTime.now();
    final payload = '${id}_${_getTagFromNotificationType(type)}';
    if (toBeDeliveredOn.isBefore(now) || toBeDeliveredOn.isAtSameMomentAs(now)) {
      await showNotification(id, type, title, body, payload: payload);
      return;
    }
    final newId = _generateUniqueId(id, type);
    final specifics = _getPlatformChannelSpecifics(type, body);
    final scheduledDate = tz.TZDateTime.from(toBeDeliveredOn, _location);
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      newId,
      title,
      body,
      scheduledDate,
      specifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  void _setDefaultTimeZone() {
    _location = tz.getLocation(_fallbackTimeZone);
    tz.setLocalLocation(_location);
  }

  NotificationDetails _getPlatformChannelSpecifics(AppNotificationType type, String body) {
    final style = body.length < 40 ? null : BigTextStyleInformation(body);
    final android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
      styleInformation: style,
      largeIcon: const DrawableResourceAndroidBitmap(_largeIcon),
      tag: _getTagFromNotificationType(type),
    );
    const iOS = DarwinNotificationDetails();

    return NotificationDetails(android: android, iOS: iOS);
  }

  String _getTagFromNotificationType(AppNotificationType type) {
    final val = EnumToString.convertToString(type);
    return val;
  }

  // For some reason I need to provide a unique id even if I'm providing a custom tag
  // That's why we generate this id here
  int _generateUniqueId(int id, AppNotificationType type) {
    final prefix = _getIdPrefix(type).toString();
    final newId = '$prefix$id';
    return int.parse(newId);
  }

  int _getIdPrefix(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.sync:
        return 10;
      case AppNotificationType.recurringTransactions:
        return 20;
      case AppNotificationType.reports:
        return 30;
      default:
        throw Exception('The provided type = $type is not a valid notification type');
    }
  }
}

import 'dart:async';

import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';

abstract class NotificationService {
  StreamController<AppNotification> get selectNotificationStream;

  Future<void> init();

  Future<void> dispose();

  Future<void> registerCallBacks();

  Future<bool> requestIOSPermissions();

  Future<void> showNotificationWithoutId(AppNotificationType type, String title, String body, {String? payload});

  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload});

  Future<void> cancelNotification(int id, AppNotificationType type);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn);
}

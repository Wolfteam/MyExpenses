import 'package:my_expenses/domain/enums/enums.dart';

typedef IosCallBack = Function(int id, String? title, String? body, String? payload);
typedef AndroidCallBack = Function(String? payload);

abstract class NotificationService {
  void init();

  Future<void> registerCallBacks({IosCallBack? onIosReceiveLocalNotification, AndroidCallBack? onSelectNotification});

  Future<bool> requestIOSPermissions();

  Future<void> showNotificationWithoutId(AppNotificationType type, String title, String body, {String? payload});

  Future<void> showNotification(int id, AppNotificationType type, String title, String body, {String? payload});

  Future<void> cancelNotification(int id, AppNotificationType type);

  Future<void> cancelAllNotifications();

  Future<void> scheduleNotification(int id, AppNotificationType type, String title, String body, DateTime toBeDeliveredOn);
}

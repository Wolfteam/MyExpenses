import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    String? msg,
    required NotificationType type,
    String? payload,
  }) = _AppNotification;

  factory AppNotification.openFile(String path, NotificationType type) => AppNotification(type: type, payload: path);

  factory AppNotification.openTransaction(int id) => AppNotification(
        type: NotificationType.openTransactionDetails,
        payload: '$id',
      );

  factory AppNotification.nothing() => const AppNotification(type: NotificationType.msg);

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
}

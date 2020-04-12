import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../common/enums/notification_type.dart';

part 'app_notification.g.dart';

@JsonSerializable()
class AppNotification extends Equatable {
  final String msg;
  final NotificationType type;
  final String payload;

  @override
  List<Object> get props => [msg, payload, type];

  const AppNotification({
    @required this.type,
    this.msg,
    this.payload,
  });

  factory AppNotification.openPdf(String path) =>
      AppNotification(type: NotificationType.openPdf, payload: path);

  factory AppNotification.openTransaction(int id) => AppNotification(
        type: NotificationType.openTransactionDetails,
        payload: '$id',
      );

  factory AppNotification.nothing() =>
      const AppNotification(type: NotificationType.msg);

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}

import 'package:flutter/widgets.dart' show Color, IconData;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'payment_method_item.freezed.dart';

@freezed
sealed class PaymentMethodItem with _$PaymentMethodItem {
  const factory PaymentMethodItem({
    required int id,
    int? userId,
    required String name,
    required PaymentMethodType type,
    IconData? icon,
    Color? iconColor,
    int? statementCloseDay,
    int? paymentDueDay,
    int? creditLimitMinor,
    @Default(false) bool isArchived,
    @Default(0) int sortOrder,
  }) = _PaymentMethodItem;
}

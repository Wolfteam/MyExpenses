import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_method_chart_item.freezed.dart';

@freezed
sealed class PaymentMethodChartItem with _$PaymentMethodChartItem {
  const factory PaymentMethodChartItem({
    required String methodName,
    IconData? icon,
    Color? iconColor,
    required double total,
    required double percentage,
  }) = _PaymentMethodChartItem;
}

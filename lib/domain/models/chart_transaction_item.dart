import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/presentation/shared/mixins/transaction_mixin.dart';

part 'chart_transaction_item.freezed.dart';

@freezed
class ChartTransactionItem with _$ChartTransactionItem, TransactionMixin {
  bool get isAnIncome => isTransactionAnIncome(value);

  Color get transactionColor => getTransactionColor(isAnIncome: isAnIncome);

  const factory ChartTransactionItem({
    required int order,
    required double value,
    @Default(false) bool dummyItem,
    Color? categoryColor,
  }) = _ChartTransactionItem;

  const ChartTransactionItem._();
}

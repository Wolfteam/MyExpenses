import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/mixins/transaction_mixin.dart';

part 'transactions_summary_per_date.freezed.dart';

@freezed
class TransactionsSummaryPerDate with _$TransactionsSummaryPerDate, TransactionMixin {
  Color get color => getTransactionColor(
        isAnIncome: isTransactionAnIncome(totalAmount),
      );

  bool get isAnIncome => isTransactionAnIncome(totalAmount);

  const TransactionsSummaryPerDate._();

  const factory TransactionsSummaryPerDate({
    required double totalAmount,
    required String dateRangeString,
  }) = _TransactionsSummaryPerDate;
}

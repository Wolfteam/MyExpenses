import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/mixins/transaction_mixin.dart';

part 'transactions_summary_per_date.freezed.dart';

@freezed
class TransactionsSummaryPerDate with _$TransactionsSummaryPerDate, TransactionMixin {
  Color get color => getTransactionColor(isAnIncome: isTransactionAnIncome(totalAmount));

  bool get isAnIncome => isTransactionAnIncome(totalAmount);

  const factory TransactionsSummaryPerDate({
    required double totalAmount,
    required String dateRangeString,
  }) = _TransactionsSummaryPerDate;

  const TransactionsSummaryPerDate._();
}

@freezed
class TransactionsSummaryPerYear with _$TransactionsSummaryPerYear, TransactionMixin {
  bool get isAnIncome => isTransactionAnIncome(totalAmount);

  const factory TransactionsSummaryPerYear({
    required double totalAmount,
    required int month,
  }) = _TransactionsSummaryPerYear;

  const TransactionsSummaryPerYear._();
}

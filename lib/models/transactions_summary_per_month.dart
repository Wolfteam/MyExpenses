import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/mixins/transaction_mixin.dart';

part 'transactions_summary_per_month.freezed.dart';

@freezed
class TransactionsSummaryPerMonth with _$TransactionsSummaryPerMonth, TransactionMixin {
  Color get color => getTransactionColor(isAnIncome: isAnIncome);

  const TransactionsSummaryPerMonth._();

  const factory TransactionsSummaryPerMonth({
    required int order,
    required double percentage,
    required bool isAnIncome,
  }) = _TransactionsSummaryPerMonth;
}

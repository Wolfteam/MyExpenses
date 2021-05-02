import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/mixins/transaction_mixin.dart';

part 'transactions_summary_per_day.freezed.dart';

@freezed
class TransactionsSummaryPerDay with _$TransactionsSummaryPerDay, TransactionMixin {
  Color get color => getTransactionColor(isAnIncome: isTransactionAnIncome(totalDayAmount));

  const factory TransactionsSummaryPerDay({
    required DateTime date,
    required double totalDayAmount,
  }) = _TransactionsSummaryPerDay;

  const TransactionsSummaryPerDay._();
}

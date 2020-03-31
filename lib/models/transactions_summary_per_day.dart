import 'package:flutter/material.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerDay with TransactionMixin {
  final DateTime date;
  final double totalDayAmount;

  Color get color => getTransactionColor(
        isAnIncome: isTransactionAnIncome(totalDayAmount),
      );

  TransactionsSummaryPerDay({
    @required this.date,
    @required this.totalDayAmount,
  });
}

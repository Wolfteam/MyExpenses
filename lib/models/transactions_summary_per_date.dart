import 'package:flutter/material.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerDate with TransactionMixin {
  final double totalAmount;
  final String dateRangeString;

  Color get color => getTransactionColor(
        isAnIncome: isTransactionAnIncome(totalAmount),
      );

  bool get isAnIncome => isTransactionAnIncome(totalAmount);

  TransactionsSummaryPerDate(
    this.totalAmount,
    this.dateRangeString,
  );
}

import 'package:flutter/material.dart';

class TransactionsSummaryPerMonth {
  final int order;
  final int percentage;
  final bool isAnIncome;

  Color get color {
    return isAnIncome ? Colors.green : Colors.red;
  }

  TransactionsSummaryPerMonth({
    this.order,
    this.percentage,
    this.isAnIncome,
  });
}

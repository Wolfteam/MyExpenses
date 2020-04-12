import 'package:flutter/material.dart';

class TransactionMixin {
  bool isTransactionAnIncome(double amount) {
    return amount >= 0;
  }

  Color getTransactionColor({
    bool isAnIncome,
  }) {
    return isAnIncome ? Colors.green : Colors.red;
  }
}

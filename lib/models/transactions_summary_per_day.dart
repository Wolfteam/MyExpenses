import 'package:flutter/material.dart';
import 'package:my_expenses/models/base_transaction.dart';

class TransactionsSummaryPerDay extends BaseTransaction {
  TransactionsSummaryPerDay({
    @required DateTime date,
    @required int amount,
  }) : super.withDate(amount: amount, createdAt: date);
}

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerDay extends Equatable with TransactionMixin {
  final DateTime date;
  final double totalDayAmount;

  @override
  List<Object> get props => [date, totalDayAmount];

  Color get color => getTransactionColor(
        isAnIncome: isTransactionAnIncome(totalDayAmount),
      );

  TransactionsSummaryPerDay({
    @required this.date,
    @required this.totalDayAmount,
  });
}

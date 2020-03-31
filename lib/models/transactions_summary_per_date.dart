import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerDate extends Equatable with TransactionMixin {
  final double totalAmount;
  final String dateRangeString;

  @override
  List<Object> get props => [totalAmount, dateRangeString];

  Color get color => getTransactionColor(
        isAnIncome: isTransactionAnIncome(totalAmount),
      );

  bool get isAnIncome => isTransactionAnIncome(totalAmount);

  TransactionsSummaryPerDate(
    this.totalAmount,
    this.dateRangeString,
  );
}

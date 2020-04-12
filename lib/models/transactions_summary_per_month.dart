import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerMonth extends Equatable with TransactionMixin {
  final int order;
  final double percentage;
  final bool isAnIncome;

  @override
  List<Object> get props => [order, percentage, isAnIncome];

  Color get color => getTransactionColor(isAnIncome: isAnIncome);

  TransactionsSummaryPerMonth({
    @required this.order,
    @required this.percentage,
    @required this.isAnIncome,
  });
}

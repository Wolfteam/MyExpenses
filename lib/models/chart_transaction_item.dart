import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/mixins/transaction_mixin.dart';

class ChartTransactionItem extends Equatable with TransactionMixin {
  final int order;
  final double value;
  final bool dummyItem;
  final Color categoryColor;

  @override
  List<Object> get props => [order, value, dummyItem, categoryColor];

  bool get isAnIncome => isTransactionAnIncome(value);

  Color get transactionColor => getTransactionColor(isAnIncome: isAnIncome);

  ChartTransactionItem({
    @required this.value,
    @required this.order,
    this.categoryColor,
    this.dummyItem = false,
  });
}

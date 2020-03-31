import 'package:flutter/material.dart';

import '../common/mixins/transaction_mixin.dart';

class TransactionsSummaryPerMonth with TransactionMixin {
  final int order;
  final double percentage;
  final bool isAnIncome;

  Color get color => getTransactionColor(isAnIncome: isAnIncome);

  TransactionsSummaryPerMonth({
    @required this.order,
    @required this.percentage,
    @required this.isAnIncome,
  });
}

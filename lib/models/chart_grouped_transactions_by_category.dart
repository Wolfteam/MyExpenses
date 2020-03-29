import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../common/utils/transaction_utils.dart';
import 'category_item.dart';
import 'transaction_item.dart';

class ChartGroupedTransactionsByCategory extends Equatable {
  final CategoryItem category;
  final List<TransactionItem> transactions;

  double get total => TransactionUtils.getTotalTransactionAmount(transactions);

  @override
  List<Object> get props => [category, transactions];

  const ChartGroupedTransactionsByCategory({
    @required this.category,
    @required this.transactions,
  });
}

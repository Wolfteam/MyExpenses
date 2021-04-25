import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/common/utils/transaction_utils.dart';

import 'category_item.dart';
import 'transaction_item.dart';

part 'chart_grouped_transactions_by_category.freezed.dart';

@freezed
class ChartGroupedTransactionsByCategory with _$ChartGroupedTransactionsByCategory {
  double get total => TransactionUtils.getTotalTransactionAmount(transactions);

  const ChartGroupedTransactionsByCategory._();

  const factory ChartGroupedTransactionsByCategory({
    required CategoryItem category,
    required List<TransactionItem> transactions,
  }) = _ChartGroupedTransactionsByCategory;
}

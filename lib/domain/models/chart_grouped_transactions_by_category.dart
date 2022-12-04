import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/category_item.dart';
import 'package:my_expenses/domain/models/transaction_item.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'chart_grouped_transactions_by_category.freezed.dart';

@freezed
class ChartGroupedTransactionsByCategory with _$ChartGroupedTransactionsByCategory {
  double get total => TransactionUtils.getTotalTransactionAmount(transactions);

  const factory ChartGroupedTransactionsByCategory({
    required CategoryItem category,
    required List<TransactionItem> transactions,
  }) = _ChartGroupedTransactionsByCategory;

  const ChartGroupedTransactionsByCategory._();
}

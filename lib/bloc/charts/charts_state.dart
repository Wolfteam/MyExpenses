part of 'charts_bloc.dart';

@freezed
class ChartsState with _$ChartsState {
  double get totalIncomeAmount =>
      transactions.where((t) => t.category.isAnIncome == true).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));

  double get totalExpenseAmount =>
      transactions.where((t) => t.category.isAnIncome == false).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));

  const ChartsState._();

  const factory ChartsState.loaded({
    required DateTime currentDate,
    required String currentDateString,
    required List<TransactionsSummaryPerDate> transactionsPerDate,
    required List<TransactionItem> transactions,
    required AppLanguageType language,
  }) = _Loaded;

  static List<ChartTransactionItem> incomeChartTransactions(List<TransactionItem> transactions) => _buildChartTransactionItems(transactions, true);

  static List<ChartTransactionItem> expenseChartTransactions(List<TransactionItem> transactions) => _buildChartTransactionItems(transactions, false);

  static List<ChartTransactionItem> _buildChartTransactionItems(List<TransactionItem> transactions, bool onlyIncomes) {
    final items = <ChartTransactionItem>[];
    final cats = transactions.where((t) => t.category.isAnIncome == onlyIncomes).select((element, index) => element.category.id).distinct().toList();

    for (var i = 0; i < cats.length; i++) {
      final catId = cats[i];
      final category = transactions.firstWhere((t) => t.category.id == catId).category;
      final double amount = transactions.where((t) => t.category.id == catId).map((e) => e.amount).sum;
      items.add(ChartTransactionItem(
        value: amount,
        order: i,
        categoryColor: category.iconColor,
      ));
    }

    return items;
  }
}
//
// class LoadedState extends ChartsState {
//   final DateTime currentDate;
//   final String currentDateString;
//   final List<TransactionsSummaryPerDate> transactionsPerDate;
//   final List<TransactionItem> transactions;
//   final AppLanguageType language;
//
//   double get totalIncomeAmount =>
//       transactions.where((t) => t.category.isAnIncome == true).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));
//
//   double get totalExpenseAmount =>
//       transactions.where((t) => t.category.isAnIncome == false).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));
//
//   List<ChartTransactionItem> get incomeChartTransactions => _buildChartTransactionItems(true);
//
//   List<ChartTransactionItem> get expenseChartTransactions => _buildChartTransactionItems(false);
//
//   List<ChartTransactionItem> _buildChartTransactionItems(
//     bool onlyIncomes,
//   ) {
//     return transactions
//         .where((t) => t.category.isAnIncome == onlyIncomes)
//         .map((t) => ChartTransactionItem(
//               value: t.amount,
//               order: transactions.indexOf(t),
//               categoryColor: t.category.iconColor,
//             ))
//         .toList();
//   }
// }

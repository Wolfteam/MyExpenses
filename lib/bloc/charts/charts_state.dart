part of 'charts_bloc.dart';

abstract class ChartsState extends Equatable {
  @override
  List<Object> get props => [];

  const ChartsState();
}

class LoadingState extends ChartsState {}

class LoadedState extends ChartsState {
  final DateTime currentDate;
  final String currentDateString;
  final List<TransactionsSummaryPerDate> transactionsPerDate;
  final List<TransactionItem> transactions;
  final AppLanguageType language;

  double get totalIncomeAmount => transactions
      .where((t) => t.category.isAnIncome == true)
      .map((t) => t.amount)
      .fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));
  double get totalExpenseAmount => transactions
      .where((t) => t.category.isAnIncome == false)
      .map((t) => t.amount)
      .fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));

  List<ChartTransactionItem> get incomeChartTransactions =>
      _buildChartTransactionItems(true);
  List<ChartTransactionItem> get expenseChartTransactions =>
      _buildChartTransactionItems(false);

  @override
  List<Object> get props => [
        currentDate,
        currentDateString,
        transactionsPerDate,
        transactions,
        language
      ];

  const LoadedState(
    this.currentDate,
    this.currentDateString,
    this.transactionsPerDate,
    this.transactions,
    this.language,
  );

  List<ChartTransactionItem> _buildChartTransactionItems(
    bool onlyIncomes,
  ) {
    return transactions
        .where((t) => t.category.isAnIncome == onlyIncomes)
        .map((t) => ChartTransactionItem(
              value: t.amount,
              order: transactions.indexOf(t),
              categoryColor: t.category.iconColor,
            ))
        .toList();
  }
}

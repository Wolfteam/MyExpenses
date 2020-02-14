part of 'transactions_bloc.dart';

@immutable
abstract class TransactionsState {
  const TransactionsState();
}

class TransactionsInitialState extends TransactionsState {}

class TransactionsLoadedState extends TransactionsState {
  final String month;
  final double incomeAmount;
  final double expenseAmount;
  final double balanceAmount;

  final List<TransactionsSummaryPerMonth> monthBalance;
  final List<TransactionCardItems> transactionsPerMonth;
  final List<TransactionsSummaryPerDay> incomeTransactionsPerWeek;
  final List<TransactionsSummaryPerDay> expenseTransactionsPerWeek;

  const TransactionsLoadedState({
    @required this.month,
    @required this.incomeAmount,
    @required this.expenseAmount,
    @required this.balanceAmount,
    @required this.monthBalance,
    @required this.transactionsPerMonth,
    @required this.incomeTransactionsPerWeek,
    @required this.expenseTransactionsPerWeek,
  });
}
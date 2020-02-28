part of 'transactions_bloc.dart';

@immutable
abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object> get props => [];
}

class TransactionsInitialState extends TransactionsState {}

class TransactionsLoadedState extends TransactionsState {
  final String month;
  final double incomeAmount;
  final double expenseAmount;
  final double balanceAmount;
  final DateTime currentDate;
  final bool showLast7Days;

  final List<TransactionsSummaryPerMonth> monthBalance;
  final List<TransactionCardItems> transactionsPerMonth;
  final List<TransactionsSummaryPerDay> incomeTransactionsPerWeek;
  final List<TransactionsSummaryPerDay> expenseTransactionsPerWeek;

  const TransactionsLoadedState({
    @required this.month,
    @required this.incomeAmount,
    @required this.expenseAmount,
    @required this.balanceAmount,
    @required this.currentDate,
    @required this.showLast7Days,
    @required this.monthBalance,
    @required this.transactionsPerMonth,
    @required this.incomeTransactionsPerWeek,
    @required this.expenseTransactionsPerWeek,
  });

  @override
  List<Object> get props => [
        month,
        incomeAmount,
        expenseAmount,
        balanceAmount,
        currentDate,
        showLast7Days,
        monthBalance,
        transactionsPerMonth,
        incomeTransactionsPerWeek,
        expenseTransactionsPerWeek
      ];
}

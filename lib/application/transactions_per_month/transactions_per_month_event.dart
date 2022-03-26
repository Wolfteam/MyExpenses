part of 'transactions_per_month_bloc.dart';

@freezed
class TransactionsPerMonthEvent with _$TransactionsPerMonthEvent {
  const factory TransactionsPerMonthEvent.init({
    required double incomes,
    required double expenses,
    required double total,
    required String month,
    required List<TransactionsSummaryPerMonth> transactions,
    required DateTime currentDate,
  }) = _Init;
}

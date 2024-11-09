part of 'transactions_last_7_days_bloc.dart';

@freezed
class TransactionsLast7DaysEvent with _$TransactionsLast7DaysEvent {
  const factory TransactionsLast7DaysEvent.init({
    required List<TransactionsSummaryPerDay> incomes,
    required List<TransactionsSummaryPerDay> expenses,
    TransactionType? selectedType,
    @Default(true) bool showLast7Days,
  }) = _Init;
}

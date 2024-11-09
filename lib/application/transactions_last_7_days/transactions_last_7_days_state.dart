part of 'transactions_last_7_days_bloc.dart';

@freezed
class TransactionsLast7DaysState with _$TransactionsLast7DaysState {
  const factory TransactionsLast7DaysState.loading() = _LoadingState;
  const factory TransactionsLast7DaysState.initial({
    required bool showLast7Days,
    required List<TransactionsSummaryPerDay> incomes,
    required List<TransactionsSummaryPerDay> expenses,
  }) = _InitialState;
}

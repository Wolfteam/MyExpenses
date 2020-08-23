part of 'transactions_last_7_days_bloc.dart';

@freezed
abstract class TransactionsLast7DaysState implements _$TransactionsLast7DaysState {
  factory TransactionsLast7DaysState.initial() = TransactionsLast7DaysInitialState;
  factory TransactionsLast7DaysState.loaded({
    @required bool showLast7Days,
    @required TransactionType selectedType,
    @required List<TransactionsSummaryPerDay> incomes,
    @required List<TransactionsSummaryPerDay> expenses,
  }) = TransactionsLast7DaysLoadedState;
}

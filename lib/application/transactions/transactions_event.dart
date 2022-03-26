part of 'transactions_bloc.dart';

@freezed
class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.loadTransactions({
    required DateTime inThisDate,
  }) = _LoadTransactions;

  const factory TransactionsEvent.loadRecurringTransactions() = _LoadRecurringTransactions;
}

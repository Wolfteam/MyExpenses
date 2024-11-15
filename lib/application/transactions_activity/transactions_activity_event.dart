part of 'transactions_activity_bloc.dart';

@freezed
class TransactionsActivityEvent with _$TransactionsActivityEvent {
  const factory TransactionsActivityEvent.init() = _Init;

  const factory TransactionsActivityEvent.dateChanged({
    required DateTime date,
  }) = _DateChanged;

  const factory TransactionsActivityEvent.dateRangeChanged({
    required TransactionActivityDateRangeType type,
  }) = _DateRangeChanged;

  const factory TransactionsActivityEvent.activitySelected({
    required TransactionActivityType type,
  }) = _ActivitySelected;
}

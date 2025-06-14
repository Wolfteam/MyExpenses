part of 'transactions_activity_bloc.dart';

@freezed
sealed class TransactionsActivityEvent with _$TransactionsActivityEvent {
  const factory TransactionsActivityEvent.init() = TransactionsActivityEventInit;

  const factory TransactionsActivityEvent.dateChanged({required DateTime currentDate}) = TransactionsActivityEventDateChanged;

  const factory TransactionsActivityEvent.dateRangeChanged({required TransactionActivityDateRangeType type}) =
      TransactionsActivityEventDateRangeChanged;

  const factory TransactionsActivityEvent.activitySelected({required TransactionActivityType type}) =
      TransactionsActivityEventActivitySelected;
}

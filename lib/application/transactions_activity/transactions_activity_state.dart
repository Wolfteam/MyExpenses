part of 'transactions_activity_bloc.dart';

@freezed
class TransactionsActivityState with _$TransactionsActivityState {
  const factory TransactionsActivityState.loaded({
    required bool loaded,
    required DateTime currentDate,
    required double balance,
    required TransactionActivityDateRangeType type,
    required List<TransactionActivityType> selectedActivityTypes,
    required List<TransactionActivityPerDate> transactions,
  }) = _LoadedState;
}

part of 'transactions_bloc.dart';

@freezed
class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.init({
    required DateTime currentDate,
  }) = _Init;

  const factory TransactionsEvent.groupingTypeChanged({
    required TransactionFilterType type,
  }) = _GroupTypeChanged;

  const factory TransactionsEvent.sortDirectionTypeChanged({
    required SortDirectionType type,
  }) = _SortTypeChanged;
}

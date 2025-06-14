part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.init({required DateTime currentDate}) = TransactionsEventInit;

  const factory TransactionsEvent.groupingTypeChanged({required TransactionFilterType type}) = TransactionsEventGroupTypeChanged;

  const factory TransactionsEvent.sortDirectionTypeChanged({required SortDirectionType type}) = TransactionsEventSortTypeChanged;
}

part of 'search_bloc.dart';

@freezed
sealed class SearchEvent with _$SearchEvent {
  const factory SearchEvent.init() = SearchEventInit;

  const factory SearchEvent.loadMore() = SearchEventLoadMore;

  const factory SearchEvent.descriptionChanged({required String newValue}) = SearchEventDescriptionChanged;

  const factory SearchEvent.applyTempDates() = SearchEventApplyTempDates;

  const factory SearchEvent.tempFromDateChanged({DateTime? newValue}) = SearchEventTempFromDateChanged;

  const factory SearchEvent.tempToDateChanged({DateTime? newValue}) = SearchEventTempToDateChanged;

  const factory SearchEvent.resetTempDates() = SearchEventResetTempDates;

  const factory SearchEvent.applyTempAmount() = SearchEventApplyTempAmount;

  const factory SearchEvent.tempAmountChanged({double? newValue}) = SearchEventTempAmountChanged;

  const factory SearchEvent.tempComparerTypeChanged({required ComparerType newValue}) = SearchEventTempComparerTypeChanged;

  const factory SearchEvent.comparerTypeChanged({required ComparerType newValue}) = SearchEventComparerTypeChanged;

  const factory SearchEvent.categoryChanged({CategoryItem? newValue}) = SearchEventCategoryChanged;

  const factory SearchEvent.transactionFilterChanged({required TransactionFilterType newValue}) =
      SearchEventTransactionFilterChanged;

  const factory SearchEvent.sortDirectionChanged({required SortDirectionType newValue}) = SearchEventSortDirectionChanged;

  const factory SearchEvent.transactionTypeChanged({required TransactionType? newValue}) = SearchEventTransactionTypeChanged;
}

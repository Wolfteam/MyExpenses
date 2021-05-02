part of 'search_bloc.dart';

@freezed
class SearchEvent with _$SearchEvent {
  const factory SearchEvent.init() = _Init;

  const factory SearchEvent.loadMore() = _LoadMore;

  const factory SearchEvent.descriptionChanged({
    required String newValue,
  }) = _DescriptionChanged;

  const factory SearchEvent.applyTempDates() = _ApplyTempDates;

  const factory SearchEvent.tempFromDateChanged({
    DateTime? newValue,
  }) = _TempFromDateChanged;

  const factory SearchEvent.tempToDateChanged({
    DateTime? newValue,
  }) = _TempToDateChanged;

  const factory SearchEvent.resetTempDates() = _ResetTempDates;

  const factory SearchEvent.applyTempAmount() = _ApplyTempAmount;

  const factory SearchEvent.tempAmountChanged({
    double? newValue,
  }) = _TempAmountChanged;

  const factory SearchEvent.tempComparerTypeChanged({
    required ComparerType newValue,
  }) = _TempComparerTypeChanged;

  const factory SearchEvent.comparerTypeChanged({
    required ComparerType newValue,
  }) = _ComparerTypeChanged;

  const factory SearchEvent.categoryChanged({
    CategoryItem? newValue,
  }) = _CategoryChanged;

  const factory SearchEvent.transactionFilterChanged({
    required TransactionFilterType newValue,
  }) = _TransactionFilterChanged;

  const factory SearchEvent.sortDirectionChanged({
    required SortDirectionType newValue,
  }) = _SortDirectionChanged;

  const factory SearchEvent.transactionTypeChanged({
    required TransactionType? newValue,
  }) = _TransactionTypeChanged;
}

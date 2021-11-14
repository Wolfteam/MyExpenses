part of 'chart_details_bloc.dart';

@freezed
class ChartDetailsEvent with _$ChartDetailsEvent {
  const factory ChartDetailsEvent.initialize({
    required List<TransactionItem> transactions,
  }) = _Initialize;

  const factory ChartDetailsEvent.filterChanged({
    required TransactionFilterType selectedFilter,
  }) = _FilterChanged;

  const factory ChartDetailsEvent.sortDirectionChanged({
    required SortDirectionType selectedDirection,
  }) = _SortDirectionChanged;
}

part of 'charts_bloc.dart';

@freezed
sealed class ChartsState with _$ChartsState {
  const factory ChartsState.loaded({
    required bool loaded,
    required ChartPeriodType selectedPeriod,
    DateTime? customStart,
    DateTime? customEnd,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required List<CategoryChartItem> topCategories,
    required List<TransactionActivityPerDate> monthlyPoints,
  }) = ChartsStateLoaded;
}

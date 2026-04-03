part of 'trend_chart_bloc.dart';

@freezed
sealed class TrendChartState with _$TrendChartState {
  const factory TrendChartState.loaded({
    required bool loaded,
    required List<TransactionActivityPerDate> trendPoints,
    required List<TransactionActivityPerDate> monthlyPoints,
  }) = TrendChartStateLoaded;
}

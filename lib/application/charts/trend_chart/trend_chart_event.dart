part of 'trend_chart_bloc.dart';

@freezed
sealed class TrendChartEvent with _$TrendChartEvent {
  const factory TrendChartEvent.load({
    required DateTime from,
    required DateTime to,
  }) = TrendChartEventLoad;
}

part of 'category_chart_bloc.dart';

@freezed
sealed class CategoryChartEvent with _$CategoryChartEvent {
  const factory CategoryChartEvent.load({
    required DateTime from,
    required DateTime to,
  }) = CategoryChartEventLoad;
}

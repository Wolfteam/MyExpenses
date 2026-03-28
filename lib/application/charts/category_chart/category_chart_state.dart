part of 'category_chart_bloc.dart';

@freezed
sealed class CategoryChartState with _$CategoryChartState {
  const factory CategoryChartState.loaded({
    required bool loaded,
    required List<CategoryChartItem> categories,
  }) = CategoryChartStateLoaded;
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_chart_item.freezed.dart';

@freezed
sealed class CategoryChartItem with _$CategoryChartItem {
  const factory CategoryChartItem({
    required String categoryName,
    required double total,
    required double percentage,
    required Color color,
    required bool isAnIncome,
  }) = _CategoryChartItem;
}

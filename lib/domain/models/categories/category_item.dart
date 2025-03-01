import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_item.freezed.dart';
part 'category_item.g.dart';

@freezed
class CategoryItem with _$CategoryItem {
  const factory CategoryItem({
    required int id,
    required bool isAnIncome,
    required String name,
    @JsonKey(includeToJson: false, includeFromJson: false) IconData? icon,
    @JsonKey(includeToJson: false, includeFromJson: false) Color? iconColor,
    @Default(false) bool isSelected,
  }) = _CategoryItem;

  factory CategoryItem.fromJson(Map<String, dynamic> json) => _$CategoryItemFromJson(json);
}

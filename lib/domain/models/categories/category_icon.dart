import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'category_icon.freezed.dart';

@freezed
sealed class CategoryIcon with _$CategoryIcon {
  const factory CategoryIcon({
    required Icon icon,
    required String name,
    required CategoryIconType type,
    @Default(false) bool isSelected,
  }) = _CategoryIcon;
}

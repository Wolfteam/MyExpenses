import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../common/enums/category_icon_type.dart';

part 'category_icon.freezed.dart';

@freezed
class CategoryIcon with _$CategoryIcon {
  const factory CategoryIcon({
    required Icon icon,
    required String name,
    required CategoryIconType type,
    @Default(false) bool isSelected,
  }) = _CategoryIcon;
}

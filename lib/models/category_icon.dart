import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/enums/category_icon_type.dart';

class CategoryIcon extends Equatable {
  final Icon icon;
  final String name;
  final CategoryIconType type;
  final bool isSelected;

  @override
  List<Object> get props => [icon, name, type, isSelected];

  const CategoryIcon({
    @required this.icon,
    @required this.name,
    @required this.type,
    this.isSelected = false,
  });
}

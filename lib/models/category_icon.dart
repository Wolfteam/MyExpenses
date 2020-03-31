import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../common/enums/category_icon_type.dart';

class CategoryIcon extends Equatable {
  Icon icon;
  String name;
  CategoryIconType type;
  bool isSelected;

  @override
  List<Object> get props => [icon, name, type, isSelected];

  CategoryIcon({
    @required this.icon,
    @required this.name,
    @required this.type,
    this.isSelected = false,
  });
}

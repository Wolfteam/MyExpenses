import 'package:flutter/material.dart';

import '../common/enums/category_icon_type.dart';

class CategoryIcon {
  Icon icon;
  String name;
  CategoryIconType type;
  bool isSelected;

  CategoryIcon({
    @required this.icon,
    @required this.name,
    @required this.type,
    this.isSelected = false,
  });
}

import 'package:flutter/material.dart';

import 'category_item.dart';
//TODO: MAYBE REMOVE THIS
class CurrentSelectedCategory extends ChangeNotifier {
  CategoryItem? _currentSelectedItem;

  CategoryItem? get currentSelectedItem => _currentSelectedItem;

  set currentSelectedItem(CategoryItem? item) => _currentSelectedItem = item;
}

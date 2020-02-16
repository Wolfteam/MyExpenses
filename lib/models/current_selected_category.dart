import 'package:flutter/material.dart';

import '../models/category_item.dart';

class CurrentSelectedCategory extends ChangeNotifier {
  CategoryItem _currentSelectedItem;

  CategoryItem get currentSelectedItem => _currentSelectedItem;
  set currentSelectedItem(CategoryItem item) => _currentSelectedItem = item;
}

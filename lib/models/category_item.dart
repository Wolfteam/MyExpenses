import 'package:flutter/material.dart';

class CategoryItem {
  int id;
  bool isAnIncome;
  String name;
  IconData icon;
  Color iconColor;

  CategoryItem(
    this.id,
    this.isAnIncome,
    this.name,
    this.icon,
    this.iconColor,
  );
}

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryItem extends Equatable {
  final int id;
  final bool isAnIncome;
  final String name;
  final IconData icon;
  final Color iconColor;
  final bool isSeleted;

  @override
  List<Object> get props => [id, isAnIncome, name, icon, iconColor, isSeleted];

  const CategoryItem({
    @required this.id,
    @required this.isAnIncome,
    @required this.name,
    @required this.icon,
    @required this.iconColor,
    this.isSeleted = false,
  });

  CategoryItem copyWith({
    int id,
    bool isAnIncome,
    String name,
    IconData icon,
    Color iconColor,
    bool isSeleted = false,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      isAnIncome: isAnIncome ?? this.isAnIncome,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isSeleted: isSeleted ?? this.isSeleted,
    );
  }
}

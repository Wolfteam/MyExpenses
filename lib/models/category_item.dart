import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_item.g.dart';

@JsonSerializable()
class CategoryItem extends Equatable {
  final int id;
  final bool isAnIncome;
  final String name;

  @JsonKey(ignore: true)
  final IconData icon;

  @JsonKey(ignore: true)
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

  factory CategoryItem.fromJson(Map<String, dynamic> json) =>
      _$CategoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryItemToJson(this);
}

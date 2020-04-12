import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'category.g.dart';

@JsonSerializable()
class Category extends Equatable {
  final String name;
  final bool isAnIncome;
  final String icon;
  final int iconColor;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;

  @override
  List<Object> get props => [];

  const Category({
    @required this.name,
    @required this.isAnIncome,
    @required this.icon,
    @required this.iconColor,
    @required this.createdAt,
    @required this.createdBy,
    @required this.createdHash,
    @required this.updatedAt,
    @required this.updatedBy,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

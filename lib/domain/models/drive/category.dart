import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
sealed class Category with _$Category {
  const factory Category({
    required String name,
    required bool isAnIncome,
    required String icon,
    required int iconColor,
    required DateTime createdAt,
    required String createdBy,
    required String createdHash,
    DateTime? updatedAt,
    String? updatedBy,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

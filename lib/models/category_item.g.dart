// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryItem _$CategoryItemFromJson(Map<String, dynamic> json) {
  return CategoryItem(
    id: json['id'] as int,
    isAnIncome: json['isAnIncome'] as bool,
    name: json['name'] as String,
    isSeleted: json['isSeleted'] as bool,
  );
}

Map<String, dynamic> _$CategoryItemToJson(CategoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isAnIncome': instance.isAnIncome,
      'name': instance.name,
      'isSeleted': instance.isSeleted,
    };

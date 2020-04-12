// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppFile _$AppFileFromJson(Map<String, dynamic> json) {
  return AppFile(
    transactions: (json['transactions'] as List)
        ?.map((e) =>
            e == null ? null : Transaction.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    categories: (json['categories'] as List)
        ?.map((e) =>
            e == null ? null : Category.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AppFileToJson(AppFile instance) => <String, dynamic>{
      'transactions': instance.transactions,
      'categories': instance.categories,
    };

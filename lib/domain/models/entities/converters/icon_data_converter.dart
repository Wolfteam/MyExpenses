import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';

class IconDataConverter extends TypeConverter<IconData?, String?> {
  const IconDataConverter();

  @override
  IconData? fromSql(String? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return CategoryUtils.fromJSONString(fromDb);
  }

  @override
  String? toSql(IconData? value) {
    if (value == null) {
      return null;
    }
    return CategoryUtils.toJSONString(value);
  }
}

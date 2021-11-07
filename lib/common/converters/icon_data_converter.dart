import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../common/utils/category_utils.dart';

class IconDataConverter extends TypeConverter<IconData, String> {
  const IconDataConverter();

  @override
  IconData? mapToDart(String? fromDb) {
    if (fromDb == null) {
      return null;
    }
    return CategoryUtils.fromJSONString(fromDb);
  }

  @override
  String? mapToSql(IconData? value) {
    if (value == null) {
      return null;
    }
    return CategoryUtils.toJSONString(value);
  }
}

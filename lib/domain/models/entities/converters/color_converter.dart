import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  Color mapToDart(int? fromDb) {
    return Color(fromDb!);
  }

  @override
  int mapToSql(Color? value) {
    return value!.value;
  }
}

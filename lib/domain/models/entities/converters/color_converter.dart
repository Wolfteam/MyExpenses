import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class ColorConverter extends TypeConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromSql(int? fromDb) {
    return Color(fromDb!);
  }

  @override
  int toSql(Color? value) {
    return value!.toARGB32();
  }
}

import 'package:flutter/material.dart';
import 'package:moor/moor.dart';

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

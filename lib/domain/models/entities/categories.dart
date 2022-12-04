import 'package:drift/drift.dart';

import 'base_entity.dart';
import 'converters/db_converters.dart';

@DataClassName('Category')
class Categories extends BaseEntity {
  TextColumn get name => text().withLength(min: 0, max: 255)();

  BoolColumn get isAnIncome => boolean()();

  TextColumn get icon => text().nullable().map(const IconDataConverter())();

  IntColumn get iconColor => integer().map(const ColorConverter())();

  IntColumn get userId => integer().nullable().customConstraint('REFERENCES users(id)')();
}

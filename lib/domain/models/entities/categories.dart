import 'package:drift/drift.dart';
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';

@DataClassName('Category')
class Categories extends BaseEntity {
  TextColumn get name => text().withLength(min: 0, max: 255)();

  BoolColumn get isAnIncome => boolean()();

  TextColumn get icon => text().nullable().map(const IconDataConverter())();

  IntColumn get iconColor => integer().map(const ColorConverter())();

  IntColumn get userId => integer().nullable().references(Users, #id)();
}

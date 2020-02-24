part of 'database.dart';

@DataClassName('Category')
class Categories extends BaseEntity {
  TextColumn get name => text().withLength(min: 0, max: 255)();
  BoolColumn get isAnIncome => boolean()();
  TextColumn get icon => text().map(const IconDataConverter())();
  IntColumn get iconColor => integer().map(const ColorConverter())();
}

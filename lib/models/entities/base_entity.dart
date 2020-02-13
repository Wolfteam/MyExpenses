import 'package:moor/moor.dart';

class BaseEntity extends Table {
  // autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();
  
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  TextColumn get createdBy => text().withLength(min: 0, max: 255)();
  
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedBy => text().nullable().withLength(min: 0, max: 255)();
}
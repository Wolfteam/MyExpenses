import 'package:moor/moor.dart';

import '../../common/converters/local_status_converter.dart';

class BaseEntity extends Table {
  // autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();

  IntColumn get localStatus => integer().map(const LocalStatusConverter())();

  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().withLength(min: 0, max: 255)();

  TextColumn get createdHash => text()();

  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedBy => text().nullable().withLength(min: 0, max: 255)();
}

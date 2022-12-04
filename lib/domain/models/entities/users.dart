import 'package:drift/drift.dart';
import 'package:my_expenses/domain/models/entities/base_entity.dart';

class Users extends BaseEntity {
  TextColumn get googleUserId => text()();

  TextColumn get name => text().withLength(min: 1, max: 255)();

  TextColumn get email => text().withLength(min: 1, max: 255)();

  TextColumn get pictureUrl => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

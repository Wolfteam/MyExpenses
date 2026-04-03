import 'package:drift/drift.dart';
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';

@DataClassName('PaymentMethod')
class PaymentMethods extends BaseEntity {
  // Per-user owner (not null)
  IntColumn get userId => integer().nullable().references(Users, #id)();

  // Display
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get type => integer().map(const PaymentTypeConverter())();
  TextColumn get icon => text().nullable().map(const IconDataConverter())();
  IntColumn get iconColor => integer().nullable().map(const ColorConverter())();

  // Credit card statement cycle metadata
  IntColumn get statementCloseDay => integer().nullable().check(statementCloseDay.isBetweenValues(1, 31))();
  IntColumn get paymentDueDay => integer().nullable().check(paymentDueDay.isBetweenValues(1, 31))();
  IntColumn get creditLimitMinor => integer().nullable()();

  // Lifecycle & sorting
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

import 'package:drift/drift.dart';
import 'package:my_expenses/domain/models/entities/base_entity.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';

class Transactions extends BaseEntity {
  RealColumn get amount => real()();

  TextColumn get description => text().withLength(min: 0, max: 255)();

  TextColumn get longDescription => text().nullable()();

  DateTimeColumn get transactionDate => dateTime()();

  IntColumn get repetitionCycle => integer().map(const RepetitionCycleConverter())();

  IntColumn get parentTransactionId => integer().nullable()();

  BoolColumn get isParentTransaction => boolean()();

  DateTimeColumn get nextRecurringDate => dateTime().nullable()();

  TextColumn get imagePath => text().nullable()();

  IntColumn get categoryId => integer().customConstraint('REFERENCES categories(id)')();
}

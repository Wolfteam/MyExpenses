part of 'database.dart';

class Transactions extends BaseEntity {
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 0, max: 255)();
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get repetitionCycle =>
      integer().map(const RepetitionCycleConverter())();
  IntColumn get parentTransactionId => integer().nullable()();
  BoolColumn get isParentTransaction => boolean()();
  DateTimeColumn get nextRecurringDate => dateTime().nullable()();
  TextColumn get imagePath => text().nullable()();

  IntColumn get categoryId =>
      integer().customConstraint('REFERENCES categories(id)')();
}

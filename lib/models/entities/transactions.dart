part of 'database.dart';

class Transactions extends BaseEntity {
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 0, max: 255)();
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get repetitions => integer()();
  IntColumn get categoryId =>
      integer().customConstraint('REFERENCES categories(id)')();

//TODO: REPETITIONS EACH MONTH, DAY ?
}

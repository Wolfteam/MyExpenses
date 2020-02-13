import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:my_expenses/models/category_item.dart';
import 'package:my_expenses/models/transaction_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'base_entity.dart';
import 'converters/icon_data_converter.dart';
import '../../common/utils/db_seed_util.dart';

//Tables
part 'users.dart';
part 'transactions.dart';
part 'categories.dart';

//daos
part '../../daos/users_dao.dart';
part '../../daos/categories_dao.dart';
part '../../daos/transactions_dao.dart';

//Generated db
part 'database.g.dart';

/*
class BaseEntity extends Table {
  // autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  TextColumn get createdBy => text().withLength(min: 0, max: 255)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get updatedBy => text().withLength(min: 0, max: 255)();
}

class Transactions extends BaseEntity {
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 0, max: 255)();
}

class Categories extends BaseEntity {
  TextColumn get name => text().withLength(min: 0, max: 255)();
  BoolColumn get isAnIncome => boolean()();
  IntColumn get color => integer()();
}*/

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    print(dbFolder.path);
    final file = File(p.join(dbFolder.path, 'my_expenses.sqlite'));
    return VmDatabase(file, logStatements: true);
  });
}

@UseMoor(
  tables: [
    Users,
    Transactions,
    Categories,
  ],
  daos: [
    UsersDao,
    TransactionsDao,
    CategoriesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        beforeOpen: (details) async {
          if (details.wasCreated) {
            await batch((b) {
              b.insertAll(categories, getDefaultCategories());
            });
            await batch((b) {
              b.insertAll(transactions, getDefaultTransactions());
            });
          }
        },
      );
}

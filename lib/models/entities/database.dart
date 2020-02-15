import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../common/enums/repetition_cycle_type.dart';
import '../../common/utils/db_seed_util.dart';
import '../../models/category_item.dart';
import '../../models/transaction_item.dart';
import 'base_entity.dart';
import 'converters/color_converter.dart';
import 'converters/icon_data_converter.dart';
import 'converters/repetition_cycle_converter.dart';

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

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    print(dbFolder.path);
    final file = File(p.join(dbFolder.path, 'my_expenses.sqlite'));
    //TODO: CHANGE THIS
    if (await file.exists()) {
      await file.delete();
    }
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
              b.insertAll(transactions, getDefaultTransactions());
            });
          }
        },
      );
}

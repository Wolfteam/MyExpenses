import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../common/converters/db_converters.dart';
import '../../common/converters/local_status_converter.dart';
import '../../common/enums/local_status_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/utils/db_seed_util.dart';
import '../../daos/categories_dao.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/category_item.dart';
import '../../models/drive/category.dart' as sync_cat;
import '../../models/drive/transaction.dart' as sync_trans;
import '../../models/transaction_item.dart';
import '../../models/user_item.dart';
import 'base_entity.dart';

part '../../daos/categories_dao_impl.dart';
part '../../daos/transactions_dao_impl.dart';
part '../../daos/users_dao_impl.dart';
part 'categories.dart';
part 'database.g.dart';
part 'transactions.dart';
part 'users.dart';

const createdBy = 'system';

String createdHash(List<Object> columns) {
  final output = AccumulatorSink<Digest>();
  final input = sha256.startChunkedConversion(output);

  for (final value in columns) {
    final bytes = utf8.encode('$value');
    input.add(bytes);
  }
  input.close();

  return output.events.single.toString();
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_expenses.sqlite'));
    // TODO: CHANGE THIS
    // if (await file.exists()) {
    //   debugPrint('********Deleting database');
    //   debugPrint('********Db path =  ${dbFolder.path}');
    //   await file.delete();
    // }
    return VmDatabase(file);
  });
}

//TODO: THE USERNAME SHOULD BE SAVED
@UseMoor(
  tables: [
    Users,
    Transactions,
    Categories,
  ],
  daos: [
    UsersDaoImpl,
    TransactionsDaoImpl,
    CategoriesDaoImpl,
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
            final defaultCats = getDefaultCategories();
            await batch((b) {
              b.insertAll(categories, defaultCats);
            });
          }
        },
      );
}

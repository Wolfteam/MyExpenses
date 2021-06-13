import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moor/ffi.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../common/converters/db_converters.dart';
import '../../common/converters/local_status_converter.dart';
import '../../common/enums/comparer_type.dart';
import '../../common/enums/local_status_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/transaction_filter_type.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/extensions/string_extensions.dart';
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
part 'running_tasks.dart';
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

Future<String> _getDatabasePath() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return p.join(dbFolder.path, 'my_expenses.sqlite');
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final path = await _getDatabasePath();
    final file = File(path);
    // TODO: CHANGE THIS
    // if (await file.exists()) {
    //   debugPrint('********Deleting database');
    //   debugPrint('********Db path =  ${dbFolder.path}');
    //   await file.delete();
    // }
    return VmDatabase(file);
  });
}

Future<DatabaseConnection> _connectAsync() async {
  final isolate = await _createMoorIsolate();
  return isolate.connect();
}

AppDatabase getIsolateDatabase() {
  return AppDatabase.connect(DatabaseConnection.delayed(_connectAsync()));
}

Future<MoorIsolate> _createMoorIsolate() async {
  // this method is called from the main isolate. Since we can't use
  // getApplicationDocumentsDirectory on a background isolate, we calculate
  // the database path in the foreground isolate and then inform the
  // background isolate about the path.
  final path = await _getDatabasePath();
  final receivePort = ReceivePort();

  await Isolate.spawn(
    _startBackground,
    _IsolateStartRequest(receivePort.sendPort, path),
  );

  // _startBackground will send the MoorIsolate to this ReceivePort
  final isolate = await receivePort.first as MoorIsolate;
  return isolate;
}

void _startBackground(_IsolateStartRequest request) {
  // this is the entry point from the background isolate! Let's create
  // the database from the path we received
  final executor = VmDatabase(File(request.targetPath));
  // we're using MoorIsolate.inCurrent here as this method already runs on a
  // background isolate. If we used MoorIsolate.spawn, a third isolate would be
  // started which is not what we want!
  final moorIsolate = MoorIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  // inform the starting isolate about this, so that it can call .connect()
  request.sendMoorIsolate.send(moorIsolate);
}

// used to bundle the SendPort and the target path, since isolate entry point
// functions can only take one parameter.
class _IsolateStartRequest {
  final SendPort sendMoorIsolate;
  final String targetPath;

  _IsolateStartRequest(this.sendMoorIsolate, this.targetPath);
}

@UseMoor(
  tables: [
    Users,
    Transactions,
    Categories,
    RunningTasks,
  ],
  daos: [
    UsersDaoImpl,
    TransactionsDaoImpl,
    CategoriesDaoImpl,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // this constructor is used by the isolates
  AppDatabase.connect(DatabaseConnection connection) : super.connect(connection);

  @override
  int get schemaVersion => 2;

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
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            //long description was added in v2
            await m.addColumn(transactions, transactions.longDescription);
          }
        },
      );
}

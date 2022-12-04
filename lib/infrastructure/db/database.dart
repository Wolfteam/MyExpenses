import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart' show Color, IconData;
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities.dart';
import 'package:my_expenses/domain/models/entities/converters/db_converters.dart';
import 'package:my_expenses/domain/utils/db_seed_util.dart';
import 'package:my_expenses/infrastructure/db/categories_dao_impl.dart';
import 'package:my_expenses/infrastructure/db/transactions_dao_impl.dart';
import 'package:my_expenses/infrastructure/db/users_dao_impl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';

part 'database.g.dart';

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
  open.overrideFor(OperatingSystem.windows, _openOnWindows);
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
    return NativeDatabase(file);
  });
}

DynamicLibrary _openOnWindows() {
  //https://www.sqlite.org/download.html
  //Precompiled Binaries for Windows
  final script = File(Platform.script.toFilePath()).parent;
  final path = '${script.path}/sqlite3.dll';
  final libraryNextToScript = File(path);
  return DynamicLibrary.open(libraryNextToScript.path);
}

Future<DatabaseConnection> _connectAsync() async {
  final isolate = await _createMoorIsolate();
  return isolate.connect();
}

AppDatabase getIsolateDatabase() {
  return AppDatabase.connect(DatabaseConnection.delayed(_connectAsync()));
}

Future<DriftIsolate> _createMoorIsolate() async {
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
  final isolate = await receivePort.first as DriftIsolate;
  return isolate;
}

void _startBackground(_IsolateStartRequest request) {
  // this is the entry point from the background isolate! Let's create
  // the database from the path we received
  final executor = NativeDatabase(File(request.targetPath));
  // we're using MoorIsolate.inCurrent here as this method already runs on a
  // background isolate. If we used MoorIsolate.spawn, a third isolate would be
  // started which is not what we want!
  final moorIsolate = DriftIsolate.inCurrent(
    () => DatabaseConnection(executor),
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

@DriftDatabase(
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
  AppDatabase.connect(super.connection) : super.connect();

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

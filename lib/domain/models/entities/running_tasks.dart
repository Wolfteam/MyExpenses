import 'package:drift/drift.dart';

import 'base_entity.dart';

class RunningTasks extends BaseEntity {
  TextColumn get name => text()();

  BoolColumn get isRunning => boolean()();
}

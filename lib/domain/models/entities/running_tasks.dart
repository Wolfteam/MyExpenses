import 'package:drift/drift.dart';
import 'package:my_expenses/domain/models/entities/base_entity.dart';

class RunningTasks extends BaseEntity {
  TextColumn get name => text()();

  BoolColumn get isRunning => boolean()();
}

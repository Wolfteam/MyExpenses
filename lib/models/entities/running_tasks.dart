part of 'database.dart';

class RunningTasks extends BaseEntity {
  TextColumn get name => text()();
  BoolColumn get isRunning => boolean()();
}

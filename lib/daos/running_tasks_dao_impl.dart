part of '../models/entities/database.dart';

@UseDao(tables: [RunningTasks])
class RunningTasksDaoImpl extends DatabaseAccessor<AppDatabase>
    with _$RunningTasksDaoImplMixin
    implements RunningTasksDao {
  RunningTasksDaoImpl(AppDatabase db) : super(db);

  @override
  Stream<List<RunningTask>> watchRunningTasks() {
    return (select(runningTasks)).watch();
  }

  @override
  Future<int> saveRunningTask(String name, {bool isRunning = true}) {
    final now = DateTime.now();
    return into(runningTasks).insert(RunningTask(
      name: name,
      createdAt: now,
      createdBy: createdBy,
      isRunning: isRunning,
      localStatus: LocalStatusType.created,
      createdHash: createdHash([
        name,
        now,
        createdBy,
        isRunning,
        LocalStatusType.created,
      ]),
    ));
  }

  @override
  Future<void> updateRunningTask(int id, {bool isRunning = false}) {
    return (update(runningTasks)..where((t) => t.id.equals(id))).write(
      RunningTasksCompanion(
        isRunning: Value(isRunning),
        updatedAt: Value(DateTime.now()),
        updatedBy: const Value(createdBy),
      ),
    );
  }
}

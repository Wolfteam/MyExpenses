import '../models/entities/database.dart';

abstract class RunningTasksDao {
  Stream<List<RunningTask>> watchRunningTasks();

  Future<int> saveRunningTask(String name, {bool isRunning = true});

  Future<void> updateRunningTask(int id, {bool isRunning = false});
}

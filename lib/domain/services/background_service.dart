import 'dart:isolate';

import 'package:my_expenses/domain/models/models.dart';

abstract class BackgroundService {
  ReceivePort get port;

  Future<void> init();

  void registerPortWithName();

  void removePortNameMapping();

  Future<void> registerRecurringTransactionsTask(BackgroundTranslations translations);

  Future<void> cancelSyncTask();

  Future<void> cancelRecurringTransactionsTask();

  Future<void> runSyncTask(BackgroundTranslations translations);

  Future<void> handleBackgroundTask(String task, BackgroundTranslations translations, {bool calledFromBg = false});
}

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../../common/enums/sync_intervals_type.dart';
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/notification_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../injection.dart';
import '../../logger.dart';
import '../../models/app_notification.dart';
import '../../models/entities/database.dart';
import '../../services/logging_service.dart';
import '../../services/network_service.dart';
import '../../services/settings_service.dart';
import '../../services/sync_service.dart';
import 'transaction_utils.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await BackgroundUtils.bgSync(task);
    return true;
  });
}

class BackgroundUtils {
  static const _syncTaskId = 'my_expenses_sync_task';
  static const _syncTaskName = 'Sync task';

  static const _recurringTransId = 'my_expenses_recurring_trans_task';
  static const _recurringTransName = 'Recurring Transactions Task';

  static const portName = 'background_port';
  static ReceivePort port = ReceivePort();

  static Future<void> initBg() {
    //TODO: CHANGE THE ISINDEBUG
    if (Platform.isAndroid) {
      return Workmanager.initialize(callbackDispatcher);
    }

    return Future.value();
  }

  static Future<void> registerSyncTask(SyncIntervalType interval) {
    Duration duration;
    if (!Platform.isAndroid) {
      throw Exception('Platform not supported');
    }

    switch (interval) {
      case SyncIntervalType.eachHour:
        duration = const Duration(hours: 1);
        break;
      case SyncIntervalType.each3Hours:
        duration = const Duration(hours: 3);
        break;
      case SyncIntervalType.each6Hours:
        duration = const Duration(hours: 6);
        break;
      case SyncIntervalType.each12Hours:
        duration = const Duration(hours: 12);
        break;
      case SyncIntervalType.eachDay:
        duration = const Duration(hours: 24);
        break;
      default:
        throw Exception(
          'Cant register sync task with the provided value = $interval',
        );
    }

    return Workmanager.registerPeriodicTask(
      _syncTaskId,
      _syncTaskName,
      frequency: duration,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
      ),
    );
  }

  static Future<void> registerRecurringTransactionsTask() {
    //The minutes part is to avoid an overlap with the sync task
    const duration = Duration(hours: 8, minutes: 20);
    if (!Platform.isAndroid) {
      return Future.value();
    }

    return Workmanager.registerPeriodicTask(
      _recurringTransId,
      _recurringTransName,
      frequency: duration,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
      ),
    );
  }

  static Future<void> cancelSyncTask() {
    return Workmanager.cancelByUniqueName(_syncTaskId);
  }

  static Future<void> bgSync(String task) async {
    initInjection();
    await setupLogging();
    final logger = getIt<LoggingService>();
    final settingsService = getIt<SettingsService>();
    await settingsService.init();
    final i18n = await getI18n(settingsService.language);
    const runtimeType = BackgroundUtils;

    try {
      switch (task) {
        case _syncTaskName:
          final SendPort sendPort = IsolateNameServer.lookupPortByName(
            portName,
          );
          sendPort?.send([true]);
          logger.info(
            runtimeType,
            'bgSync: Checking if internet is available...',
          );
          await _runSyncTask(
            logger,
            getIt<NetworkService>(),
            getIt<SyncService>(),
            settingsService,
          );
          sendPort?.send([false]);
          break;
        case _recurringTransName:
          await _runRecurringTransTask(
            logger,
            getIt<TransactionsDao>(),
            getIt<UsersDao>(),
            settingsService,
          );
          break;
        default:
          logger.warning(runtimeType, 'bgSync: Task = $task is not valid');
          throw Exception('Bg task = $task is invalid');
      }
    } catch (e, s) {
      logger.error(runtimeType, 'bgSync: Unknown error occurred', e, s);
      if (settingsService.showNotifAfterFullSync) {
        await showNotification(
          i18n.automaticSync,
          i18n.unknownErrorOcurred,
          jsonEncode(AppNotification.nothing()),
        );
      }
    } finally {
      logger.info(runtimeType, 'bgSync: Closing db connection...');
      await getIt<AppDatabase>().close();
      logger.info(runtimeType, 'bgSync: Db connection was succesfully closed');
    }

    logger.info(
      runtimeType,
      'bgSync: Process completed',
    );
  }

  static Future<void> _runSyncTask(
    LoggingService logger,
    NetworkService networkService,
    SyncService syncService,
    SettingsService settingsService,
  ) async {
    const runtimeType = BackgroundUtils;
    try {
      logger.info(
        runtimeType,
        'runBgSyncTask: Sync task is starting. Sync interval = ${settingsService.syncInterval}',
      );
      final i18n = await getI18n(settingsService.language);
      logger.info(
        runtimeType,
        'runBgSyncTask: Checking if internet is available...',
      );
      final isNetworkAvailable = await networkService.isInternetAvailable();
      if (!isNetworkAvailable) {
        logger.info(
          runtimeType,
          'runBgSyncTask: Internet is not available :C',
        );
        return;
      }

      logger.info(
        runtimeType,
        'runBgSyncTask: Downloading and updating files...',
      );
      await syncService.downloadAndUpdateFile();

      logger.info(
        runtimeType,
        'runBgSyncTask: Sync was successfully performed',
      );
      if (settingsService.showNotifAfterFullSync) {
        await showNotification(
          i18n.automaticSync,
          i18n.syncWasSuccessfullyPerformed,
          jsonEncode(AppNotification.nothing()),
        );
      }
    } catch (e, s) {
      logger.error(
        runtimeType,
        'runBgSyncTask: Unknown error occurred',
        e,
        s,
      );
      rethrow;
    }
  }

  static Future<void> _runRecurringTransTask(
    LoggingService logger,
    TransactionsDao transactionsDao,
    UsersDao usersDao,
    SettingsService settingsService,
  ) async {
    const runtimeType = BackgroundUtils;
    try {
      final i18n = await getI18n(settingsService.language);
      final now = DateTime.now();
      logger.info(
        runtimeType,
        'runBgRecurringTransTask: Checking recurring transactions for date = $now',
      );
      final childs = await TransactionUtils.checkRecurringTransactions(
        now,
        logger,
        transactionsDao,
        usersDao,
      );

      if (childs.isEmpty || !settingsService.showNotifForRecurringTrans) return;

      logger.info(
        runtimeType,
        'runBgRecurringTransTask: Show ${childs.length} child notifications...',
      );

      final futures = childs
          .map((t) => showNotification(
                i18n.recurringTransactions,
                t.description,
                jsonEncode(AppNotification.openTransaction(t.id)),
                id: t.id,
              ))
          .toList();

      await Future.wait(futures);
    } catch (e, s) {
      logger.error(
        runtimeType,
        'runBgRecurringTransTask: Unknown error occurred',
        e,
        s,
      );
      rethrow;
    }
  }
}

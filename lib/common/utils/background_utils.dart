import 'dart:convert';
import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../../common/enums/sync_intervals_type.dart';
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/notification_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../injection.dart';
import '../../logger.dart';
import '../../models/app_notification.dart';
import '../../services/logging_service.dart';
import '../../services/network_service.dart';
import '../../services/settings_service.dart';
import '../../services/sync_service.dart';
import '../../telemetry.dart';
import 'transaction_utils.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    await BackgroundUtils.bgSync(task);
    return Future.value(true);
  });
}

class BackgroundUtils {
  static const _syncTaskId = 'my_expenses_sync_task';
  static const _syncTaskName = 'Sync task';

  static const _recurringTransId = 'my_expenses_recurring_trans_task';
  static const _recurringTransName = 'Recurring Transactions Task';

  static Future<void> initBg() {
    //TODO: CHANGE THE ISINDEBUG
    if (Platform.isAndroid) {
      return Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
    }

    return Future.value();
  }

  static Future<void> registerSyncTask(SyncIntervalType interval) {
    Duration duration;
    if (!Platform.isAndroid) {
      return Future.value();
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
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> registerRecurringTransactionsTask() {
    const duration = Duration(hours: 8);
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
      ),
    );
  }

  static Future<void> cancelSyncTask() {
    return Workmanager.cancelByUniqueName(_syncTaskId);
  }

  static Future<void> bgSync(String task) async {
    initInjection();
    await setupLogging();
    await initTelemetry();
    final logger = getIt<LoggingService>();
    final settingsService = getIt<SettingsService>();
    await settingsService.init();
    final i18n = await getI18n(settingsService.language);
    const runtimeType = BackgroundUtils;
    // await setupNotifications();

    try {
      switch (task) {
        case _syncTaskName:
          logger.info(
            runtimeType,
            'bgSync: Checking if internet is available...',
          );
          final networkService = getIt<NetworkService>();
          final syncService = getIt<SyncService>();
          final isNetworkAvailable = await networkService.isInternetAvailable();
          if (!isNetworkAvailable) {
            logger.info(
              runtimeType,
              'bgSync: Internet is not available :C',
            );
            return;
          }

          logger.info(
            runtimeType,
            'bgSync: Downloading and updating files...',
          );
          await syncService.downloadAndUpdateFile();

          logger.info(
            runtimeType,
            'bgSync: Sync was successfully performed',
          );
          if (settingsService.showNotifAfterFullSync) {
            await showNotification(
              i18n.automaticSync,
              i18n.syncWasSuccessfullyPerformed,
              jsonEncode(AppNotification.nothing()),
            );
          }
          break;
        case _recurringTransName:
          final transactionsDao = getIt<TransactionsDao>();
          final now = DateTime.now();
          logger.info(
            runtimeType,
            'bgSync: Checking recurring transactions for date = $now',
          );
          final childs = await TransactionUtils.checkRecurringTransactions(
            now,
            logger,
            transactionsDao,
          );

          if (childs.isEmpty) return;

          if (settingsService.showNotifForRecurringTrans) {
            logger.info(
              runtimeType,
              'bgSync: Show ${childs.length} child notifications...',
            );

            final futures = childs
                .map((t) => showNotification(
                      i18n.recurringTransactions,
                      t.description,
                      jsonEncode(AppNotification.openTransaction(t.id)),
                    ))
                .toList();

            await Future.wait(futures);
          }
          break;
        default:
          logger.warning(runtimeType, 'bgSync: Task = $task is not valid');
          throw Exception('Bg task = $task is invalid');
      }
    } on Exception catch (e, s) {
      logger.error(runtimeType, 'bgSync: Unknown error occurred', e, s);
      if (settingsService.showNotifAfterFullSync) {
        await showNotification(
          i18n.automaticSync,
          i18n.unknownErrorOcurred,
          jsonEncode(AppNotification.nothing()),
        );
      }
    }
    logger.info(
      runtimeType,
      'bgSync: Process completed',
    );
  }
}

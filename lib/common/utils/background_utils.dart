import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../../common/enums/sync_intervals_type.dart';
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/notification_utils.dart';
import '../../injection.dart';
import '../../logger.dart';
import '../../services/logging_service.dart';
import '../../services/network_service.dart';
import '../../services/settings_service.dart';
import '../../services/sync_service.dart';
import '../../telemetry.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    await BackgroundUtils.bgSync(task);
    return Future.value(true);
  });
}

class BackgroundUtils {
  static const _syncTaskId = '1';
  static const _syncTaskName = 'Sync task';

  static Future<void> initBg() {
    if (Platform.isAndroid) {
      return Workmanager.initialize(callbackDispatcher, isInDebugMode: true);
    }

    return Future.value();
  }

  static Future<void> registerSyncTask(SyncIntervalType interval) {
    Duration duration;
    if (!Platform.isAndroid) {
      return Future.value();
    }

    return Workmanager.registerOneOffTask(
      _syncTaskId,
      _syncTaskName,
    );

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
      case SyncIntervalType.none:
        return Workmanager.cancelByUniqueName(_syncTaskId);
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

  static Future<void> bgSync(String task) async {
    initInjection();
    await setupLogging();
    await initTelemetry();
    final logger = getIt<LoggingService>();
    final networkService = getIt<NetworkService>();
    final syncService = getIt<SyncService>();
    final settingsService = getIt<SettingsService>();
    await settingsService.init();
    final i18n = await getI18n(settingsService.language);
    const runtimeType = BackgroundUtils;
    final isNetworkAvailable = await networkService.isInternetAvailable();

    try {
      switch (task) {
        case _syncTaskName:
          logger.info(
            runtimeType,
            'bgSync: Checking if internet is available...',
          );
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
          showNotification(
            i18n.automaticSync,
            i18n.syncWasSuccessfullyPerformed,
          );
          break;
        default:
          logger.warning(runtimeType, 'bgSync: Task = $task is not valid');
          throw Exception('Bg task = $task is invalid');
      }
    } on Exception catch (e, s) {
      logger.error(runtimeType, 'bgSync: Unknown error occurred', e, s);
      showNotification(
        i18n.automaticSync,
        i18n.unknownErrorOcurred,
      );
    }
  }
}

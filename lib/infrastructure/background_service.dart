import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/infrastructure/db/database.dart';
import 'package:my_expenses/injection.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:workmanager/workmanager.dart';

void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      //WORKAROUND FOR https://github.com/flutter/flutter/issues/98473
      if (Platform.isAndroid) {
        SharedPreferencesAndroid.registerWith();
        PathProviderAndroid.registerWith();
      }
      final bgService = await Injection.getBackgroundService(forBgTask: true);
      await bgService.handleBackgroundTask(task, BackgroundTranslations.fromJson(inputData!), calledFromBg: true);
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }
    return true;
  });
}

const _syncNotificationId = 1;
const _syncTaskId = 'my_expenses_sync_task';
const _syncTaskName = 'Sync task';

const _recurringTransId = 'my_expenses_recurring_trans_task';
const _recurringTransName = 'Recurring Transactions Task';

const _portName = 'background_port';

class BackgroundServiceImpl implements BackgroundService {
  final LoggingService _logger;
  final SettingsService _settingsService;
  final NetworkService _networkService;
  final SyncService _syncService;
  final NotificationService _notificationService;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final AppDatabase _db;

  final ReceivePort _port = ReceivePort();

  @override
  ReceivePort get port => _port;

  BackgroundServiceImpl(
    this._networkService,
    this._syncService,
    this._logger,
    this._settingsService,
    this._notificationService,
    this._transactionsDao,
    this._usersDao,
    this._db,
  );

  @override
  Future<void> init() {
    if (Platform.isAndroid) {
      return Workmanager().initialize(_callbackDispatcher);
    }

    return Future.value();
  }

  @override
  void registerPortWithName() {
    //For some reason it seems that I have to remove the port mapping before registering it
    removePortNameMapping();
    IsolateNameServer.registerPortWithName(port.sendPort, _portName);
  }

  @override
  void removePortNameMapping() {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  @override
  Future<void> registerRecurringTransactionsTask(BackgroundTranslations translations) {
    //The minutes part is to avoid an overlap with the sync task
    const duration = Duration(hours: 8, minutes: 20);
    if (!Platform.isAndroid) {
      return Future.value();
    }

    return Workmanager().registerPeriodicTask(
      _recurringTransId,
      _recurringTransName,
      frequency: duration,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
      ),
      inputData: translations.toJson(),
    );
  }

  @override
  Future<void> cancelSyncTask() {
    if (!Platform.isAndroid) {
      return Future.value();
    }
    return Workmanager().cancelByUniqueName(_syncTaskId);
  }

  @override
  Future<void> cancelRecurringTransactionsTask() {
    if (!Platform.isAndroid) {
      return Future.value();
    }
    return Workmanager().cancelByUniqueName(_recurringTransId);
  }

  @override
  Future<void> runSyncTask(BackgroundTranslations translations) async {
    await handleBackgroundTask(_syncTaskName, translations);
    _settingsService.setNextSyncDate();
  }

  @override
  Future<void> handleBackgroundTask(String task, BackgroundTranslations translations, {bool calledFromBg = false}) async {
    if (!Platform.isAndroid) {
      return Future.value();
    }

    final sendPort = IsolateNameServer.lookupPortByName(_portName);
    sendPort?.send([true]);
    try {
      switch (task) {
        case _syncTaskName:
          if (calledFromBg) {
            _logger.error(runtimeType, 'bgSync: Task = $task was called from bg and this is no longer supported');
            return;
          }
          await _runSyncTask(translations);
          break;
        case _recurringTransName:
          await _runRecurringTransTask(translations);
          break;
        default:
          _logger.warning(runtimeType, 'bgSync: Task = $task is not valid');
          throw Exception('Bg task = $task is invalid');
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'bgSync: Unknown error occurred', e, s);
      if (_settingsService.showNotifAfterFullSync) {
        await _notificationService.showNotification(
          _syncNotificationId,
          AppNotificationType.sync,
          translations.automaticSync,
          translations.unknownErrorOccurred,
          payload: jsonEncode(AppNotification.nothing()),
        );
      }
    } finally {
      sendPort?.send([false]);
      if (calledFromBg) {
        _logger.info(runtimeType, 'bgSync: Closing db connection...');
        await _db.close();
        _logger.info(runtimeType, 'bgSync: Db connection was successfully closed');
      }
    }

    _logger.info(runtimeType, 'bgSync: Process completed');
  }

  Future<void> _runSyncTask(BackgroundTranslations translations) async {
    try {
      _logger.info(runtimeType, 'runBgSyncTask: Sync task is starting. Sync interval = ${_settingsService.syncInterval}');
      _logger.info(runtimeType, 'runBgSyncTask: Checking if internet is available...');
      final isNetworkAvailable = await _networkService.isInternetAvailable();
      if (!isNetworkAvailable) {
        _logger.info(runtimeType, 'runBgSyncTask: Internet is not available :C');
        return;
      }

      _logger.info(runtimeType, 'runBgSyncTask: Downloading and updating files...');
      await _syncService.downloadAndUpdateFile();

      _logger.info(runtimeType, 'runBgSyncTask: Sync was successfully performed');
      if (_settingsService.showNotifAfterFullSync) {
        await _notificationService.showNotification(
          _syncNotificationId,
          AppNotificationType.sync,
          translations.automaticSync,
          translations.syncWasSuccessfullyPerformed,
          payload: jsonEncode(AppNotification.nothing()),
        );
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'runBgSyncTask: Unknown error occurred', e, s);
      rethrow;
    }
  }

  Future<void> _runRecurringTransTask(BackgroundTranslations translations) async {
    try {
      final now = DateTime.now();
      _logger.info(runtimeType, 'runBgRecurringTransTask: Checking recurring transactions for date = $now');
      final currentUser = await _usersDao.getActiveUser();
      final children = await _transactionsDao.saveRecurringTransactions(now, currentUser?.id);

      if (children.isEmpty || !_settingsService.showNotifForRecurringTrans) {
        return;
      }

      _logger.info(runtimeType, 'runBgRecurringTransTask: Show ${children.length} child notifications...');

      final futures = children
          .map(
            (t) => _notificationService.showNotification(
              t.id,
              AppNotificationType.recurringTransactions,
              translations.recurringTransactions,
              t.description,
              payload: jsonEncode(AppNotification.openTransaction(t.id)),
            ),
          )
          .toList();

      await Future.wait(futures);
    } catch (e, s) {
      _logger.error(runtimeType, 'runBgRecurringTransTask: Unknown error occurred', e, s);
      rethrow;
    }
  }
}

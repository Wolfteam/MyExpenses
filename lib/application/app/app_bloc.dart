import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoggingService _logger;
  final SettingsService _settingsService;
  final DrawerBloc _drawerBloc;
  final BackgroundService _backgroundService;
  final DeviceInfoService _deviceInfoService;

  late StreamSubscription _portSubscription;

  AppBloc(
    this._logger,
    this._settingsService,
    this._drawerBloc,
    this._backgroundService,
    this._deviceInfoService,
  ) : super(const AppState.loading()) {
    _listenBgPort();
  }

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    final s = await event.map(
      init: (e) async => _init(e.translations),
      themeChanged: (e) async {
        _logger.info(runtimeType, 'App theme changed, the selected theme is: ${e.theme}');
        return _loadThemeData(e.theme, _settingsService.accentColor, _settingsService.language);
      },
      accentColorChanged: (e) async {
        _logger.info(runtimeType, 'App accent color changed, the selected color is: ${e.accentColor}');
        return _loadThemeData(_settingsService.appTheme, e.accentColor, _settingsService.language);
      },
      bgTaskIsRunning: (e) async => _loadThemeData(
        _settingsService.appTheme,
        _settingsService.accentColor,
        _settingsService.language,
        bgTaskIsRunning: e.isRunning,
      ),
      languageChanged: (e) async => _loadThemeData(_settingsService.appTheme, _settingsService.accentColor, e.newValue),
      loadTheme: (e) async => AppState.loading(theme: _settingsService.appTheme, accentColor: _settingsService.accentColor),
      registerRecurringBackgroundTask: (e) async {
        await _registerRecurringBackgroundTask(e.translations);
        return state;
      },
    );

    yield s;
  }

  @override
  Future<void> close() async {
    _backgroundService.removePortNameMapping();
    await _portSubscription.cancel();
    await super.close();
  }

  Future<AppState> _init(BackgroundTranslations translations) async {
    // If the user comes from this version,
    // we need to do a log out due to the changes made in the 1.2.3
    final forceSignOut = _deviceInfoService.versionChanged && _deviceInfoService.previousBuildVersion < 46;
    if (forceSignOut) {
      await _registerRecurringBackgroundTask(translations);
      _drawerBloc.add(const DrawerEvent.signOut());
    }

    // If the user comes from this version,
    // we need to re register the background task due to all the changes made in 1.2.0
    if (_deviceInfoService.versionChanged && _deviceInfoService.previousBuildVersion < 39) {
      await _backgroundService.cancelSyncTask();
      await _registerRecurringBackgroundTask(translations);
      await _backgroundService.registerSyncTask(_settingsService.syncInterval, translations);
    }

    if (!_settingsService.isRecurringTransTaskRegistered) {
      _logger.info(runtimeType, 'Recurring trans task is not registered, registering it...');
      await _registerRecurringBackgroundTask(translations);
    }

    _logger.info(runtimeType, 'Current settings are: ${_settingsService.appSettings.toJson()}');

    await Future.delayed(const Duration(milliseconds: 500));

    return _loadThemeData(_settingsService.appTheme, _settingsService.accentColor, _settingsService.language, forceSignOut: forceSignOut);
  }

  AppState _loadThemeData(
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language, {
    bool isInitialized = true,
    bool bgTaskIsRunning = false,
    bool forceSignOut = false,
  }) {
    return AppState.loaded(
      isInitialized: isInitialized,
      theme: theme,
      accentColor: accentColor,
      bgTaskIsRunning: bgTaskIsRunning,
      language: _settingsService.getLanguageModel(language),
      forcedSignOut: forceSignOut,
    );
  }

  void _listenBgPort() {
    _backgroundService.registerPortWithName();
    _portSubscription = _backgroundService.port.listen((data) {
      final isRunning = data[0] as bool;
      add(AppEvent.bgTaskIsRunning(isRunning: isRunning));
      if (!isRunning) {
        _drawerBloc.add(const DrawerEvent.selectedItemChanged(selectedPage: AppDrawerItemType.transactions));
      }
    });
  }

  Future<void> _registerRecurringBackgroundTask(BackgroundTranslations translations) async {
    await _backgroundService.cancelRecurringTransactionsTask();
    await _backgroundService.registerRecurringTransactionsTask(translations);
    _settingsService.isRecurringTransTaskRegistered = true;
  }
}

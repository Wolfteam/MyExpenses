import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_drawer_item_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../common/utils/app_path_utils.dart';
import '../../common/utils/background_utils.dart';
import '../../generated/i18n.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';
import '../drawer/drawer_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoggingService _logger;
  final SettingsService _settingsService;
  final DrawerBloc _drawerBloc;
  StreamSubscription _portSubscription;

  AppBloc(
    this._logger,
    this._settingsService,
    this._drawerBloc,
  ) : super(AppUninitializedState()) {
    IsolateNameServer.registerPortWithName(
      BackgroundUtils.port.sendPort,
      BackgroundUtils.portName,
    );
    _portSubscription = BackgroundUtils.port.listen((data) {
      final isRunning = data[0] as bool;
      add(BgTaskIsRunning(isRunning: isRunning));
      if (!isRunning) {
        _drawerBloc.add(
          const DrawerItemSelectionChanged(AppDrawerItemType.transactions),
        );
      }
    });
  }

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    _logger.info(runtimeType, 'Initializing app settings');
    await _settingsService.init();

    if (event is AuthenticateUser) {
      yield* _authenticateUser(event);
    }

    if (event is InitializeApp) {
      await BackgroundUtils.initBg();
      try {
        _logger.info(runtimeType, 'Deleting old logs...');
        await AppPathUtils.deleteOlLogs();
      } catch (e, s) {
        _logger.error(runtimeType, 'Unknown error while deleting old logs', e, s);
      }

      if (!_settingsService.isRecurringTransTaskRegistered) {
        _logger.info(
          runtimeType,
          'Recurring trans task is not registered, registering it...',
        );
        await BackgroundUtils.registerRecurringTransactionsTask();
        _settingsService.isRecurringTransTaskRegistered = true;
      }
      _logger.info(
        runtimeType,
        'Current settings are: ${_settingsService.appSettings.toJson()}',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      yield* _loadThemeData(
        _settingsService.appTheme,
        _settingsService.accentColor,
        _settingsService.language,
      );
    }

    if (event is AppThemeChanged) {
      _logger.info(
        runtimeType,
        'App theme changed, the selected theme is: ${event.theme}',
      );
      yield* _loadThemeData(
        event.theme,
        _settingsService.accentColor,
        _settingsService.language,
      );
    }

    if (event is AppAccentColorChanged) {
      _logger.info(
        runtimeType,
        'App accent color changed, the selected color is: ${event.accentColor}',
      );

      yield* _loadThemeData(
        _settingsService.appTheme,
        event.accentColor,
        _settingsService.language,
      );
    }

    if (event is BgTaskIsRunning) {
      yield* _loadThemeData(
        _settingsService.appTheme,
        _settingsService.accentColor,
        _settingsService.language,
        bgTaskIsRunning: event.isRunning,
      );
    }
  }

  @override
  Future<void> close() async {
    IsolateNameServer.removePortNameMapping(BackgroundUtils.portName);
    await _portSubscription.cancel();
    await super.close();
  }

  Stream<AppState> _loadThemeData(
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language, {
    bool isInitialized = true,
    bool bgTaskIsRunning = false,
  }) async* {
    final themeData = accentColor.getThemeData(theme);
    _setLocale(language);
    yield AppInitializedState(
      themeData,
      isInitialized: isInitialized,
      bgTaskIsRunning: bgTaskIsRunning,
    );
  }

  void _setLocale(AppLanguageType language) {
    final locale = I18n.delegate.supportedLocales[language.index];
    I18n.onLocaleChanged(locale);
  }

  Stream<AppState> _authenticateUser(AuthenticateUser event) async* {
    final themeData = _settingsService.accentColor.getThemeData(
      _settingsService.appTheme,
    );
    final currentState = state;
    int retries = 0;
    _setLocale(_settingsService.language);

    if (currentState is AuthenticationState) {
      retries = currentState.retries + 1;
    }

    yield AuthenticationState(
      retries: retries,
      askForPassword: _settingsService.askForPassword,
      askForFingerPrint: _settingsService.askForFingerPrint,
      theme: themeData,
    );
  }
}

import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/common/utils/app_path_utils.dart';
import 'package:my_expenses/generated/l10n.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_drawer_item_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../common/utils/background_utils.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';
import '../drawer/drawer_bloc.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoggingService _logger;
  final SettingsService _settingsService;
  final DrawerBloc _drawerBloc;
  late StreamSubscription _portSubscription;

  AppBloc(
    this._logger,
    this._settingsService,
    this._drawerBloc,
  ) : super(const AppState.loading()) {
    IsolateNameServer.registerPortWithName(
      BackgroundUtils.port.sendPort,
      BackgroundUtils.portName,
    );
    _portSubscription = BackgroundUtils.port.listen((data) {
      final isRunning = data[0] as bool;
      add(AppEvent.bgTaskIsRunning(isRunning: isRunning));
      if (!isRunning) {
        _drawerBloc.add(const DrawerEvent.selectedItemChanged(selectedPage: AppDrawerItemType.transactions));
      }
    });
  }

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    _logger.info(runtimeType, 'Initializing app settings');
    await _settingsService.init();

    final s = await event.map(
      init: (e) async {
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

        return _loadThemeData(
          _settingsService.appTheme,
          _settingsService.accentColor,
          _settingsService.language,
        );
      },
      themeChanged: (e) async {
        _logger.info(
          runtimeType,
          'App theme changed, the selected theme is: ${e.theme}',
        );
        return _loadThemeData(
          e.theme,
          _settingsService.accentColor,
          _settingsService.language,
        );
      },
      accentColorChanged: (e) async {
        _logger.info(
          runtimeType,
          'App accent color changed, the selected color is: ${e.accentColor}',
        );

        return _loadThemeData(
          _settingsService.appTheme,
          e.accentColor,
          _settingsService.language,
        );
      },
      authenticateUser: (e) async => _authenticateUser(e),
      bgTaskIsRunning: (e) async => _loadThemeData(
        _settingsService.appTheme,
        _settingsService.accentColor,
        _settingsService.language,
        bgTaskIsRunning: e.isRunning,
      ),
    );

    yield s;
  }

  @override
  Future<void> close() async {
    IsolateNameServer.removePortNameMapping(BackgroundUtils.portName);
    await _portSubscription.cancel();
    await super.close();
  }

  AppState _loadThemeData(
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language, {
    bool isInitialized = true,
    bool bgTaskIsRunning = false,
  }) {
    final themeData = accentColor.getThemeData(theme);
    _setLocale(language);
    return AppState.loaded(isInitialized: isInitialized, theme: themeData, bgTaskIsRunning: bgTaskIsRunning);
  }

  void _setLocale(AppLanguageType language) {
    final locale = S.delegate.supportedLocales[language.index];
    //TODO: THIS
    // S.onLocaleChanged(locale);
  }

  Future<AppState> _authenticateUser(_AuthenticateUser event) async {
    final themeData = _settingsService.accentColor.getThemeData(_settingsService.appTheme);
    final currentState = state;
    int retries = 0;
    _setLocale(_settingsService.language);

    if (currentState is _AuthState) {
      retries = currentState.retries + 1;
    }

    return AppState.auth(
      retries: retries,
      askForPassword: _settingsService.askForPassword,
      askForFingerPrint: _settingsService.askForFingerPrint,
      theme: themeData,
    );
  }
}

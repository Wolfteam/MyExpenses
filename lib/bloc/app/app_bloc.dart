import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/models/language_model.dart';

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

const _languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
  AppLanguageType.spanish: LanguageModel('es', 'ES'),
};

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
    _listenBgPort();
  }

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    final s = await event.map(
      init: (e) async {
        await BackgroundUtils.initBg();

        if (!_settingsService.isRecurringTransTaskRegistered) {
          _logger.info(runtimeType, 'Recurring trans task is not registered, registering it...');
          await BackgroundUtils.registerRecurringTransactionsTask();
          _settingsService.isRecurringTransTaskRegistered = true;
        }
        _logger.info(runtimeType, 'Current settings are: ${_settingsService.appSettings.toJson()}');

        await Future.delayed(const Duration(milliseconds: 500));

        return _loadThemeData(_settingsService.appTheme, _settingsService.accentColor, _settingsService.language);
      },
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
      loadTheme: (e) async {
        final themeData = _settingsService.accentColor.getThemeData(_settingsService.appTheme);
        return AppState.loading(theme: themeData);
      },
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
    return AppState.loaded(
      isInitialized: isInitialized,
      theme: themeData,
      bgTaskIsRunning: bgTaskIsRunning,
      language: _getCurrentLanguage(language),
    );
  }

  LanguageModel _getCurrentLanguage(AppLanguageType language) {
    return _languagesMap.entries.firstWhere((kvp) => kvp.key == language).value;
  }

  void _listenBgPort() {
    //For some reason it seems that I have to remove the port mapping
    IsolateNameServer.removePortNameMapping(BackgroundUtils.portName);
    IsolateNameServer.registerPortWithName(BackgroundUtils.port.sendPort, BackgroundUtils.portName);
    _portSubscription = BackgroundUtils.port.listen((data) {
      final isRunning = data[0] as bool;
      add(AppEvent.bgTaskIsRunning(isRunning: isRunning));
      if (!isRunning) {
        _drawerBloc.add(const DrawerEvent.selectedItemChanged(selectedPage: AppDrawerItemType.transactions));
      }
    });
  }
}

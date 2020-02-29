import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../generated/i18n.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final LoggingService _logger;
  final SettingsService _settingsService;

  @override
  AppState get initialState => AppUninitializedState();

  AppBloc(this._logger, this._settingsService);

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is InitializeApp) {
      await Future.delayed(const Duration(seconds: 2));

      _logger.info(runtimeType, 'Initializing app settings');
      await _settingsService.init();

      _logger.info(
        runtimeType,
        'Current settings are: ${_settingsService.appSettings.toJson()}',
      );
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
  }

  Stream<AppState> _loadThemeData(
    AppThemeType theme,
    AppAccentColorType accentColor,
    AppLanguageType language,
  ) async* {
    final themeData = accentColor.getThemeData(theme);
    final locale = I18n.delegate.supportedLocales[language.index];
    I18n.onLocaleChanged(locale);

    yield AppInitializedState(themeData, locale);
  }
}

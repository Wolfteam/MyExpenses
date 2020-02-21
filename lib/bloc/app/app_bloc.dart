import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/common/enums/app_language_type.dart';
import 'package:my_expenses/generated/i18n.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/extensions/app_theme_type_extensions.dart';
import '../../services/settings_service.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final SettingsService settingsService;

  @override
  AppState get initialState => AppUninitializedState();

  AppBloc(this.settingsService);

  @override
  Stream<AppState> mapEventToState(
    AppEvent event,
  ) async* {
    if (event is! AppThemeChanged) {
      await settingsService.init();

      yield* _loadThemeData(
        settingsService.appTheme,
        settingsService.accentColor,
        settingsService.language,
      );
    }

    if (event is AppThemeChanged) {
      yield* _loadThemeData(event.theme, settingsService.accentColor, settingsService.language);
    }

    if (event is AppAccentColorChanged) {
      yield* _loadThemeData(settingsService.appTheme, event.accentColor, settingsService.language);
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

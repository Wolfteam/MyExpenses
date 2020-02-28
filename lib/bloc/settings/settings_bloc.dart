import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../generated/i18n.dart';
import '../../services/settings_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;

  SettingsBloc(this._settingsService);

  SettingsInitialState get currentState => state as SettingsInitialState;

  @override
  SettingsState get initialState => const SettingsLoadingState();

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is LoadSettings) {
      yield* _buildInitialState();
    }

    if (event is AppThemeChanged) {
      _settingsService.appTheme = event.selectedAppTheme;
      yield currentState.copyWith(appTheme: event.selectedAppTheme);
    }

    if (event is AppAccentColorChanged) {
      _settingsService.accentColor = event.selectedAccentColor;
      yield currentState.copyWith(accentColor: event.selectedAccentColor);
    }

    if (event is AppLanguageChanged) {
      _settingsService.language = event.selectedLanguage;
      final locale =
          I18n.delegate.supportedLocales[event.selectedLanguage.index];
      I18n.onLocaleChanged(locale);
      yield currentState.copyWith(appLanguage: event.selectedLanguage);
    }

    if (event is SyncIntervalChanged) {
      _settingsService.syncInterval = event.selectedSyncInterval;
      yield currentState.copyWith(syncInterval: event.selectedSyncInterval);
    }
  }

  Stream<SettingsState> _buildInitialState() async* {
    final appSettings = _settingsService.appSettings;
    final packageInfo = await PackageInfo.fromPlatform();
    
    yield SettingsInitialState(
      appTheme: appSettings.appTheme,
      useDarkAmoled: false,
      accentColor: appSettings.accentColor,
      appLanguage: appSettings.appLanguage,
      syncInterval: appSettings.syncInterval,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
    );
  }
}

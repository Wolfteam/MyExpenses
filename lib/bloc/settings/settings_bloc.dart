import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
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

    if (event is AskForPasswordChanged) {
      _settingsService.askForPassword = event.ask;
      if (!event.ask) {
        _settingsService.password = null;
      }

      if (event.ask) {
        yield currentState.copyWith(
          askForPassword: event.ask,
          askForFingerPrint: false,
        );
      } else {
        yield currentState.copyWith(askForPassword: event.ask);
      }
    }

    if (event is AskForFingerPrintChanged) {
      _settingsService.askForFingerPrint = event.ask;

      if (event.ask) {
        _settingsService.password = null;
        yield currentState.copyWith(
          askForPassword: false,
          askForFingerPrint: event.ask,
        );
      } else {
        yield currentState.copyWith(askForFingerPrint: event.ask);
      }
    }
  }

  Stream<SettingsState> _buildInitialState() async* {
    final appSettings = _settingsService.appSettings;
    final packageInfo = await PackageInfo.fromPlatform();
    final localAuth = LocalAuthentication();
    final availableBiometrics = await localAuth.getAvailableBiometrics();

    yield SettingsInitialState(
      appTheme: appSettings.appTheme,
      useDarkAmoled: false,
      accentColor: appSettings.accentColor,
      appLanguage: appSettings.appLanguage,
      syncInterval: appSettings.syncInterval,
      askForPassword: appSettings.askForPassword,
      canUseFingerPrint:
          availableBiometrics.contains(BiometricType.fingerprint),
      askForFingerPrint: appSettings.askForFingerPrint,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
    );
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/currency_symbol_type.dart';
import '../../common/enums/secure_resource_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/utils/background_utils.dart';
import '../../daos/users_dao.dart';
import '../../generated/i18n.dart';
import '../../services/secure_storage_service.dart';
import '../../services/settings_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final SecureStorageService _secureStorageService;
  final UsersDao _usersDao;

  SettingsBloc(
    this._settingsService,
    this._secureStorageService,
    this._usersDao,
  );

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
      await BackgroundUtils.cancelSyncTask();
      await BackgroundUtils.registerSyncTask(event.selectedSyncInterval);
      yield currentState.copyWith(syncInterval: event.selectedSyncInterval);
    }

    if (event is AskForPasswordChanged) {
      _settingsService.askForPassword = event.ask;
      if (!event.ask) {
        await _secureStorageService.delete(
          SecureResourceType.loginPassword,
          _secureStorageService.defaultUsername,
        );
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
        await _secureStorageService.delete(
          SecureResourceType.loginPassword,
          _secureStorageService.defaultUsername,
        );
        yield currentState.copyWith(
          askForPassword: false,
          askForFingerPrint: event.ask,
        );
      } else {
        yield currentState.copyWith(askForFingerPrint: event.ask);
      }
    }

    if (event is CurrencyChanged) {
      _settingsService.currencySymbol = event.selectedCurrency;
      yield currentState.copyWith(currencySymbol: event.selectedCurrency);
    }

    if (event is CurrencyPlacementChanged) {
      _settingsService.currencyToTheRight = event.placeToTheRight;
      yield currentState.copyWith(currencyToTheRight: event.placeToTheRight);
    }

    if (event is ShowNotifAfterFullSyncChanged) {
      _settingsService.showNotifAfterFullSync = event.show;
      yield currentState.copyWith(showNotifAfterFullSync: event.show);
    }

    if (event is ShowNotifForRecurringTransChanged) {
      _settingsService.showNotifForRecurringTrans = event.show;
      yield currentState.copyWith(showNotifForRecurringTrans: event.show);
    }
  }

  Stream<SettingsState> _buildInitialState() async* {
    final appSettings = _settingsService.appSettings;
    final packageInfo = await PackageInfo.fromPlatform();
    final localAuth = LocalAuthentication();
    final availableBiometrics = await localAuth.getAvailableBiometrics();
    final currentUser = await _usersDao.getActiveUser();

    yield SettingsInitialState(
      appTheme: appSettings.appTheme,
      useDarkAmoled: false,
      accentColor: appSettings.accentColor,
      appLanguage: appSettings.appLanguage,
      isUserLoggedIn: currentUser != null,
      syncInterval: appSettings.syncInterval,
      showNotifAfterFullSync: appSettings.showNotifAfterFullSync,
      askForPassword: appSettings.askForPassword,
      canUseFingerPrint:
          availableBiometrics.contains(BiometricType.fingerprint),
      askForFingerPrint: appSettings.askForFingerPrint,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      currencySymbol: appSettings.currencySymbol,
      currencyToTheRight: appSettings.currencyToTheRight,
      showNotifForRecurringTrans: appSettings.showNotifForRecurringTrans,
    );
  }
}

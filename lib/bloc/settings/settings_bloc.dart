import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:package_info/package_info.dart';

import '../../common/enums/app_accent_color_type.dart';
import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/currency_symbol_type.dart';
import '../../common/enums/secure_resource_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/utils/background_utils.dart';
import '../../daos/users_dao.dart';
import '../../services/secure_storage_service.dart';
import '../../services/settings_service.dart';

part 'settings_bloc.freezed.dart';
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
  ) : super(const SettingsState.loading());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    final s = await event.map(
      load: (_) async => _buildInitialState(),
      appThemeChanged: (e) async {
        _settingsService.appTheme = e.selectedAppTheme;
        return currentState.copyWith(appTheme: e.selectedAppTheme);
      },
      appAccentColorChanged: (e) async {
        _settingsService.accentColor = e.selectedAccentColor;
        return currentState.copyWith(accentColor: e.selectedAccentColor);
      },
      appLanguageChanged: (e) async {
        _settingsService.language = e.selectedLanguage;
        //TODO: THIS
        final locale = S.delegate.supportedLocales[e.selectedLanguage.index];
        // I18n.onLocaleChanged(locale);
        return currentState.copyWith(appLanguage: e.selectedLanguage);
      },
      syncIntervalChanged: (e) async {
        _settingsService.syncInterval = e.selectedSyncInterval;
        await BackgroundUtils.cancelSyncTask();
        await BackgroundUtils.registerSyncTask(e.selectedSyncInterval);
        return currentState.copyWith(syncInterval: e.selectedSyncInterval);
      },
      askForPasswordChanged: (e) async {
        _settingsService.askForPassword = e.ask;
        if (!e.ask) {
          await _secureStorageService.delete(
            SecureResourceType.loginPassword,
            _secureStorageService.defaultUsername,
          );
        }

        if (e.ask) {
          return currentState.copyWith(askForPassword: e.ask, askForFingerPrint: false);
        }
        return currentState.copyWith(askForPassword: e.ask);
      },
      askForFingerPrintChanged: (e) async {
        _settingsService.askForFingerPrint = e.ask;

        if (e.ask) {
          await _secureStorageService.delete(
            SecureResourceType.loginPassword,
            _secureStorageService.defaultUsername,
          );
          return currentState.copyWith(askForPassword: false, askForFingerPrint: e.ask);
        }
        return currentState.copyWith(askForFingerPrint: e.ask);
      },
      currencyChanged: (e) async {
        _settingsService.currencySymbol = e.selectedCurrency;
        return currentState.copyWith(currencySymbol: e.selectedCurrency);
      },
      currencyPlacementChanged: (e) async {
        _settingsService.currencyToTheRight = e.placeToTheRight;
        return currentState.copyWith(currencyToTheRight: e.placeToTheRight);
      },
      showNotificationAfterFullSyncChanged: (e) async {
        _settingsService.showNotifAfterFullSync = e.show;
        return currentState.copyWith(showNotificationAfterFullSync: e.show);
      },
      showNotificationForRecurringTransChanged: (e) async {
        _settingsService.showNotifForRecurringTrans = e.show;
        return currentState.copyWith(showNotificationForRecurringTrans: e.show);
      },
    );

    yield s;
  }

  Future<SettingsState> _buildInitialState() async {
    final appSettings = _settingsService.appSettings;
    final packageInfo = await PackageInfo.fromPlatform();
    final localAuth = LocalAuthentication();
    final availableBiometrics = await localAuth.getAvailableBiometrics();
    final currentUser = await _usersDao.getActiveUser();
    final canUseFingerPrint = await localAuth.canCheckBiometrics && await localAuth.isDeviceSupported();

    return SettingsState.initial(
      appTheme: appSettings.appTheme,
      useDarkAmoled: false,
      accentColor: appSettings.accentColor,
      appLanguage: appSettings.appLanguage,
      isUserLoggedIn: currentUser != null,
      syncInterval: appSettings.syncInterval,
      showNotificationAfterFullSync: appSettings.showNotifAfterFullSync,
      askForPassword: appSettings.askForPassword,
      canUseFingerPrint: canUseFingerPrint && availableBiometrics.contains(BiometricType.fingerprint),
      askForFingerPrint: appSettings.askForFingerPrint,
      appName: packageInfo.appName,
      appVersion: packageInfo.version,
      currencySymbol: appSettings.currencySymbol,
      currencyToTheRight: appSettings.currencyToTheRight,
      showNotificationForRecurringTrans: appSettings.showNotifForRecurringTrans,
    );
  }
}

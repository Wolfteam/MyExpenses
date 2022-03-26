import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _settingsService;
  final SecureStorageService _secureStorageService;
  final BackgroundService _backgroundService;
  final DeviceInfoService _deviceInfoService;
  final UsersDao _usersDao;
  final AppBloc _appBloc;

  SettingsBloc(
    this._settingsService,
    this._secureStorageService,
    this._backgroundService,
    this._deviceInfoService,
    this._usersDao,
    this._appBloc,
  ) : super(const SettingsState.loading());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
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
        _appBloc.add(AppEvent.languageChanged(newValue: e.selectedLanguage));
        return currentState.copyWith(appLanguage: e.selectedLanguage);
      },
      syncIntervalChanged: (e) async {
        _settingsService.syncInterval = e.selectedSyncInterval;
        await _backgroundService.cancelSyncTask();
        await _backgroundService.registerSyncTask(e.selectedSyncInterval, e.translations);
        return currentState.copyWith(syncInterval: e.selectedSyncInterval);
      },
      askForPasswordChanged: (e) async {
        _settingsService.askForPassword = e.ask;

        if (e.ask) {
          _settingsService.askForFingerPrint = false;
          return currentState.copyWith(askForPassword: e.ask, askForFingerPrint: false);
        }
        await _secureStorageService.delete(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
        return currentState.copyWith(askForPassword: e.ask);
      },
      askForFingerPrintChanged: (e) async {
        _settingsService.askForFingerPrint = e.ask;

        if (e.ask) {
          await _secureStorageService.delete(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
          _settingsService.askForPassword = false;
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
      triggerSyncTask: (e) async {
        await _backgroundService.runSyncTask(e.translations);
        return state;
      },
    );

    yield s;
  }

  Future<SettingsState> _buildInitialState() async {
    final appSettings = _settingsService.appSettings;
    final currentUser = await _usersDao.getActiveUser();

    return SettingsState.initial(
      appTheme: appSettings.appTheme,
      useDarkAmoled: false,
      accentColor: appSettings.accentColor,
      appLanguage: appSettings.appLanguage,
      isUserLoggedIn: currentUser != null,
      syncInterval: appSettings.syncInterval,
      showNotificationAfterFullSync: appSettings.showNotifAfterFullSync,
      askForPassword: appSettings.askForPassword,
      canUseFingerPrint: _deviceInfoService.canUseFingerPrint,
      askForFingerPrint: appSettings.askForFingerPrint,
      appName: _deviceInfoService.appName,
      appVersion: _deviceInfoService.version,
      currencySymbol: appSettings.currencySymbol,
      currencyToTheRight: appSettings.currencyToTheRight,
      showNotificationForRecurringTrans: appSettings.showNotifForRecurringTrans,
    );
  }
}

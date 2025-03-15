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
  ) : super(const SettingsState.loading()) {
    on<SettingsEventLoad>((event, emit) async {
      final s = await _buildInitialState();
      emit(s);
    });

    on<SettingsEventAppThemeChanged>((event, emit) {
      _settingsService.appTheme = event.selectedAppTheme;
      final s = currentState.copyWith(appTheme: event.selectedAppTheme);
      emit(s);
    });

    on<SettingsEventAppAccentColorChanged>((event, emit) {
      _settingsService.accentColor = event.selectedAccentColor;
      final s = currentState.copyWith(accentColor: event.selectedAccentColor);
      emit(s);
    });

    on<SettingsEventAppLanguageChanged>((event, emit) {
      _settingsService.language = event.selectedLanguage;
      _appBloc.add(AppEvent.languageChanged(newValue: event.selectedLanguage));
      final s = currentState.copyWith(appLanguage: event.selectedLanguage);
      emit(s);
    });

    on<SettingsEventSyncIntervalChanged>((event, emit) async {
      _settingsService.syncInterval = event.selectedSyncInterval;
      await _backgroundService.cancelSyncTask();
      final s = currentState.copyWith(syncInterval: event.selectedSyncInterval);
      emit(s);
    });

    on<SettingsEventAskForPasswordChanged>((event, emit) async {
      _settingsService.askForPassword = event.ask;
      SettingsState s;
      if (event.ask) {
        _settingsService.askForFingerPrint = false;
        s = currentState.copyWith(askForPassword: event.ask, askForFingerPrint: false);
      } else {
        await _secureStorageService.delete(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
        s = currentState.copyWith(askForPassword: event.ask);
      }
      emit(s);
    });

    on<SettingsEventAskForFingerPrintChanged>((event, emit) async {
      _settingsService.askForFingerPrint = event.ask;
      SettingsState s;
      if (event.ask) {
        await _secureStorageService.delete(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
        _settingsService.askForPassword = false;
        s = currentState.copyWith(askForPassword: false, askForFingerPrint: event.ask);
      } else {
        s = currentState.copyWith(askForFingerPrint: event.ask);
      }
      emit(s);
    });

    on<SettingsEventCurrencyChanged>((event, emit) {
      _settingsService.currencySymbol = event.selectedCurrency;
      final s = currentState.copyWith(currencySymbol: event.selectedCurrency);
      emit(s);
    });

    on<SettingsEventCurrencyPlacementChanged>((event, emit) {
      _settingsService.currencyToTheRight = event.placeToTheRight;
      final s = currentState.copyWith(currencyToTheRight: event.placeToTheRight);
      emit(s);
    });

    on<SettingsEventShowNotificationAfterFullSyncChanged>((event, emit) {
      _settingsService.showNotifAfterFullSync = event.show;
      final s = currentState.copyWith(showNotificationAfterFullSync: event.show);
      emit(s);
    });

    on<SettingsEventShowNotificationForRecurringTransChanged>((event, emit) {
      _settingsService.showNotifForRecurringTrans = event.show;
      final s = currentState.copyWith(showNotificationForRecurringTrans: event.show);
      emit(s);
    });

    on<SettingsEventTriggerSyncTask>((event, emit) async {
      await _backgroundService.runSyncTask(event.translations);
    });
  }

  SettingsStateInitialState get currentState => state as SettingsStateInitialState;

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

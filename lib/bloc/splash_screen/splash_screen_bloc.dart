import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/services/settings_service.dart';

part 'splash_screen_bloc.freezed.dart';
part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  final SettingsService _settingsService;

  SplashScreenBloc(this._settingsService) : super(const SplashScreenState.initial(retries: -1, askForPassword: false, askForFingerPrint: false));

  @override
  Stream<SplashScreenState> mapEventToState(SplashScreenEvent event) async* {
    final s = event.map(init: (_) => _authenticateUser());
    yield s;
  }

  SplashScreenState _authenticateUser() {
    final retries = state.retries + 1;

    return SplashScreenState.initial(
      retries: retries, //this is just to for a state change
      askForPassword: _settingsService.askForPassword,
      askForFingerPrint: _settingsService.askForFingerPrint,
    );
  }
}

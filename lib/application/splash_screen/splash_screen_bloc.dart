import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'splash_screen_bloc.freezed.dart';
part 'splash_screen_event.dart';
part 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  final SettingsService _settingsService;

  SplashScreenBloc(this._settingsService)
    : super(const SplashScreenState.initial(retries: -1, askForPassword: false, askForFingerPrint: false)) {
    on<SplashScreenEventInit>((event, emit) {
      final s = _authenticateUser();
      emit(s);
    });
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

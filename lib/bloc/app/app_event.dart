part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
}

class InitializeApp extends AppEvent {
  const InitializeApp();

  @override
  List<Object> get props => [];
}

class AppThemeChanged extends AppEvent {
  final AppThemeType theme;

  const AppThemeChanged(this.theme);

  @override
  List<Object> get props => [theme];
}

class AppAccentColorChanged extends AppEvent {
  final AppAccentColorType accentColor;

  const AppAccentColorChanged(this.accentColor);

  @override
  List<Object> get props => [accentColor];
}

class AuthenticateUser extends AppEvent {
  @override
  List<Object> get props => [];

  const AuthenticateUser();
}

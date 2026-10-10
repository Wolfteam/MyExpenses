part of 'user_session_bloc.dart';

@freezed
sealed class UserSessionEvent with _$UserSessionEvent {
  const factory UserSessionEvent.init() = UserSessionEventInit;
  const factory UserSessionEvent.signOut() = UserSessionEventSignOut;
}

part of 'auth_bloc.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.init() = AuthEventInit;

  const factory AuthEvent.deleteAccount({required int id}) =
      AuthEventDeleteAccount;

  const factory AuthEvent.changeActiveAccount({
    required int newActiveUserId,
  }) = AuthEventChangeActiveAccount;

  const factory AuthEvent.signIn() = AuthEventSignIn;

  const factory AuthEvent.triggerSync() = AuthEventTriggerSync;
}

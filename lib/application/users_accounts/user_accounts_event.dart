part of 'user_accounts_bloc.dart';

@freezed
class UserAccountsEvent with _$UserAccountsEvent {
  const factory UserAccountsEvent.init() = _Init;

  const factory UserAccountsEvent.deleteAccount({
    required int id,
  }) = _DeleteAccount;

  const factory UserAccountsEvent.changeActiveAccount({
    required int newActiveUserId,
  }) = _ChangeActiveAccount;

  const factory UserAccountsEvent.signIn() = _SignIn;
}

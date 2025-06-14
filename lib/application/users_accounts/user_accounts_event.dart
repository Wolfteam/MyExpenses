part of 'user_accounts_bloc.dart';

@freezed
sealed class UserAccountsEvent with _$UserAccountsEvent {
  const factory UserAccountsEvent.init() = UserAccountsEventInit;

  const factory UserAccountsEvent.deleteAccount({required int id}) = UserAccountsEventDeleteAccount;

  const factory UserAccountsEvent.changeActiveAccount({required int newActiveUserId}) = UserAccountsEventChangeActiveAccount;

  const factory UserAccountsEvent.signIn() = UserAccountsEventSignIn;
}

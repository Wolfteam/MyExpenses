part of 'user_accounts_bloc.dart';

@freezed
sealed class UserAccountsState with _$UserAccountsState {
  const factory UserAccountsState.loading() = UserAccountsEventLoadingState;

  const factory UserAccountsState.initial({
    required List<UserItem> users,
    required bool isNetworkAvailable,
    @Default(false) bool userWasDeleted,
    @Default(false) bool activeUserChanged,
    @Default(false) bool accountWasAdded,
    @Default(false) bool signInInProcess,
    @Default(null) bool? signInResult,
  }) = UserAccountsEventInitialState;
}

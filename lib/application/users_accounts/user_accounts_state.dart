part of 'user_accounts_bloc.dart';

@freezed
class UserAccountsState with _$UserAccountsState {
  const factory UserAccountsState.loading() = _LoadingState;

  const factory UserAccountsState.initial({
    required List<UserItem> users,
    required bool isNetworkAvailable,
    @Default(false) bool userWasDeleted,
    @Default(false) bool errorOccurred,
    @Default(false) bool activeUserChanged,
    @Default(false) bool accountWasAdded,
    @Default(false) bool signInInProcess,
  }) = _InitialState;
}

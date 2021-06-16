part of 'user_accounts_bloc.dart';

@freezed
class UserAccountsState with _$UserAccountsState {
  const factory UserAccountsState.initial({
    required List<UserItem> users,
    required bool userWasDeleted,
    required bool errorOccurred,
    required bool activeUserChanged,
  }) = _InitialState;

  static UserAccountsState loading() => const UserAccountsState.initial(
        users: [],
        userWasDeleted: false,
        errorOccurred: false,
        activeUserChanged: false,
      );
}

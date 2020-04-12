part of 'user_accounts_bloc.dart';

@immutable
class UserAccountsState extends Equatable {
  final List<UserItem> users;
  final bool userWasDeleted;
  final bool errorOcurred;
  final bool activeUserChanged;

  @override
  List<Object> get props => [
        users,
        userWasDeleted,
        errorOcurred,
        activeUserChanged,
      ];

  const UserAccountsState({
    @required this.users,
    this.userWasDeleted,
    this.errorOcurred,
    this.activeUserChanged,
  });

  factory UserAccountsState.initial() => const UserAccountsState(
        users: [],
        userWasDeleted: false,
        errorOcurred: false,
        activeUserChanged: false,
      );

  UserAccountsState copyWith({
    List<UserItem> users,
    bool userWasDeleted,
    bool errorOcurred,
    bool activeUserChanged,
  }) {
    return UserAccountsState(
      users: users ?? this.users,
      userWasDeleted: userWasDeleted ?? this.userWasDeleted,
      errorOcurred: errorOcurred ?? this.errorOcurred,
      activeUserChanged: activeUserChanged ?? this.activeUserChanged,
    );
  }
}

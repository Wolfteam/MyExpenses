part of 'user_accounts_bloc.dart';

abstract class UserAccountsState extends Equatable {
  const UserAccountsState();
}

class LoadingState extends UserAccountsState {
  @override
  List<Object> get props => [];
}

class UsersLoadedState extends UserAccountsState {
  final List<UserItem>  users;

  @override
  List<Object> get props => [users];

  const UsersLoadedState(this.users);
}

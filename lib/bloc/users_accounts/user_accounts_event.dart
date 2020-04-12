part of 'user_accounts_bloc.dart';

@immutable
abstract class UserAccountsEvent extends Equatable {
  const UserAccountsEvent();
}

class Initialize extends UserAccountsEvent {
  @override
  List<Object> get props => [];
}

class DeleteAccount extends UserAccountsEvent {
  final int id;

  @override
  List<Object> get props => [id];

  const DeleteAccount(this.id);
}

class ChangeActiveAccount extends UserAccountsEvent {
  final int newActiveUserId;

  @override
  List<Object> get props => [newActiveUserId];

  const ChangeActiveAccount(this.newActiveUserId);
}

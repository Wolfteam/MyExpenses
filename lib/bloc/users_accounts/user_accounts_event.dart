part of 'user_accounts_bloc.dart';

abstract class UserAccountsEvent extends Equatable {
  const UserAccountsEvent();
}

class Initialize extends UserAccountsEvent {
  @override
  List<Object> get props => [];
}

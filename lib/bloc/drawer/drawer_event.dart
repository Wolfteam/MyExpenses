part of 'drawer_bloc.dart';

abstract class DrawerEvent extends Equatable {
  const DrawerEvent();
}

class InitializeDrawer extends DrawerEvent {
  @override
  List<Object> get props => [];

  const InitializeDrawer();
}

class DrawerItemSelectionChanged extends DrawerEvent {
  final AppDrawerItemType selectedPage;

  const DrawerItemSelectionChanged(this.selectedPage);

  @override
  List<Object> get props => [selectedPage];
}

class UserSignedIn extends DrawerEvent {
  @override
  List<Object> get props => [];

  const UserSignedIn();
}

class SignOut extends DrawerEvent {
  @override
  List<Object> get props => [];

  const SignOut();
}

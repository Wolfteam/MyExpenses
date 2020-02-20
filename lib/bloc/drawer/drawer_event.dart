part of 'drawer_bloc.dart';

abstract class DrawerEvent extends Equatable {
  const DrawerEvent();
}

class DrawerItemSelectionChanged extends DrawerEvent {
  final AppDrawerItemType selectedPage;

  const DrawerItemSelectionChanged(this.selectedPage);

  @override
  List<Object> get props => [selectedPage];
}

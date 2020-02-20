part of 'drawer_bloc.dart';

class DrawerState extends Equatable {
  final AppDrawerItemType selectedPage;

  @override
  List<Object> get props => [selectedPage];

  const DrawerState(this.selectedPage);

  factory DrawerState.initial(AppDrawerItemType page) {
    return DrawerState(page);
  }
}

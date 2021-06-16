part of 'drawer_bloc.dart';

@freezed
class DrawerEvent with _$DrawerEvent {
  const factory DrawerEvent.init() = _Init;

  const factory DrawerEvent.selectedItemChanged({
    required AppDrawerItemType selectedPage,
  }) = _SelectedItemChanged;

  const factory DrawerEvent.signOut() = _SignOut;
}

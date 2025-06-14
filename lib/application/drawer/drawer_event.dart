part of 'drawer_bloc.dart';

@freezed
sealed class DrawerEvent with _$DrawerEvent {
  const factory DrawerEvent.init() = DrawerEventInit;

  const factory DrawerEvent.selectedItemChanged({required AppDrawerItemType selectedPage}) = DrawerEventSelectedItemChanged;

  const factory DrawerEvent.signOut() = DrawerEventSignOut;
}

part of 'drawer_bloc.dart';

@freezed
sealed class DrawerEvent with _$DrawerEvent {
  const factory DrawerEvent.init() = DrawerEventInit;
  const factory DrawerEvent.signOut() = DrawerEventSignOut;
}

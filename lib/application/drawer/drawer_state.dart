part of 'drawer_bloc.dart';

@freezed
class DrawerState with _$DrawerState {
  const factory DrawerState.loaded({
    required AppDrawerItemType selectedPage,
    String? fullName,
    String? email,
    String? img,
    @Default(false) bool isUserSignedIn,
    @Default(false) bool userSignedOut,
  }) = _LoadedState;
}

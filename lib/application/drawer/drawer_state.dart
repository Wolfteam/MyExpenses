part of 'drawer_bloc.dart';

@freezed
sealed class DrawerState with _$DrawerState {
  const factory DrawerState.loaded({
    required AppDrawerItemType selectedPage,
    String? fullName,
    String? email,
    String? img,
    @Default(false) bool isUserSignedIn,
    @Default(false) bool userSignedOut,
  }) = DrawerStateLoadedState;
}

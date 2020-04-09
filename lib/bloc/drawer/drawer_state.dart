part of 'drawer_bloc.dart';

class DrawerState extends Equatable {
  final AppDrawerItemType selectedPage;
  final String fullName;
  final String email;
  final String img;
  final bool isUserSignedIn;
  final bool userSignedOut;

  @override
  List<Object> get props => [
        selectedPage,
        fullName,
        email,
        img,
        isUserSignedIn,
        userSignedOut,
      ];

  const DrawerState({
    @required this.selectedPage,
    this.fullName,
    this.email,
    this.img,
    this.isUserSignedIn,
    this.userSignedOut = false,
  });

  factory DrawerState.initial(AppDrawerItemType page) {
    return DrawerState(selectedPage: page, isUserSignedIn: false);
  }

  DrawerState copyWith({
    AppDrawerItemType selectedPage,
    String fullName,
    String email,
    String img,
    bool isUserSignedIn,
    bool userSignedOut,
  }) {
    return DrawerState(
      selectedPage: selectedPage ?? this.selectedPage,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      img: img ?? this.img,
      isUserSignedIn: isUserSignedIn ?? this.isUserSignedIn,
      userSignedOut: userSignedOut ?? this.userSignedOut,
    );
  }
}

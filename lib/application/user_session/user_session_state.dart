part of 'user_session_bloc.dart';

@freezed
sealed class UserSessionState with _$UserSessionState {
  const factory UserSessionState.loaded({
    String? fullName,
    String? email,
    String? img,
    @Default(false) bool isUserSignedIn,
    @Default(false) bool userSignedOut,
  }) = UserSessionStateLoadedState;
}

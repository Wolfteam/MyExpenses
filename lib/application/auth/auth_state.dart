part of 'auth_bloc.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loading() = AuthStateLoading;

  const factory AuthState.initial({
    required List<UserItem> users,
    required bool isNetworkAvailable,
    @Default(false) bool userWasDeleted,
    @Default(false) bool activeUserChanged,
    @Default(false) bool accountWasAdded,
    @Default(false) bool signInInProcess,
    @Default(null) bool? signInResult,
  }) = AuthStateInitial;
}

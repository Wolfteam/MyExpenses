part of 'password_dialog_bloc.dart';

@freezed
sealed class PasswordDialogState with _$PasswordDialogState {
  bool get isFormValid => isPasswordValid && isConfirmPasswordValid && passwordsMatch;

  const PasswordDialogState._();

  const factory PasswordDialogState.initial({
    required String password,
    required bool isPasswordValid,
    required bool isPasswordDirty,
    required bool showPassword,
    required String confirmPassword,
    required bool isConfirmPasswordValid,
    required bool isConfirmPasswordDirty,
    required bool showConfirmPassword,
    required bool passwordsMatch,
    required bool passwordWasSaved,
    //this one can be null, and if it is, it means that the user has been validated
    bool? userIsValid,
  }) = PasswordDialogStateInitial;
}

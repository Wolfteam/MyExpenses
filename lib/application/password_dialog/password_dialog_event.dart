part of 'password_dialog_bloc.dart';

@freezed
class PasswordDialogEvent with _$PasswordDialogEvent {
  const factory PasswordDialogEvent.passwordChanged({
    required String newValue,
  }) = _PasswordChanged;

  const factory PasswordDialogEvent.showPassword({
    required bool show,
  }) = _ShowPasswod;

  const factory PasswordDialogEvent.confirmPasswordChanged({
    required String newValue,
  }) = _ConfirmPasswordChanged;

  const factory PasswordDialogEvent.showConfirmPassword({
    required bool show,
  }) = _ShowConfirmPasswod;

  const factory PasswordDialogEvent.submit() = _Submit;

  const factory PasswordDialogEvent.validatePassword({
    required String password,
  }) = _ValidatePassword;
}

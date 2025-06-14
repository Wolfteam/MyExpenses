part of 'password_dialog_bloc.dart';

@freezed
sealed class PasswordDialogEvent with _$PasswordDialogEvent {
  const factory PasswordDialogEvent.passwordChanged({required String newValue}) = PasswordDialogEventPasswordChanged;

  const factory PasswordDialogEvent.showPassword({required bool show}) = PasswordDialogEventShowPasswod;

  const factory PasswordDialogEvent.confirmPasswordChanged({required String newValue}) =
      PasswordDialogEventConfirmPasswordChanged;

  const factory PasswordDialogEvent.showConfirmPassword({required bool show}) = PasswordDialogEventShowConfirmPasswod;

  const factory PasswordDialogEvent.submit() = PasswordDialogEventSubmit;

  const factory PasswordDialogEvent.validatePassword({required String password}) = PasswordDialogEventValidatePassword;
}

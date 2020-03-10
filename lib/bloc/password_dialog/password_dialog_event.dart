part of 'password_dialog_bloc.dart';

abstract class PasswordDialogEvent extends Equatable {
  const PasswordDialogEvent();
}

abstract class _PasswordChanged extends PasswordDialogEvent {
  final String newValue;

  @override
  List<Object> get props => [newValue];

  const _PasswordChanged({@required this.newValue});
}

abstract class _ShowPassword extends PasswordDialogEvent {
  final bool show;

  @override
  List<Object> get props => [show];

  const _ShowPassword({@required this.show});
}

class PasswordChanged extends _PasswordChanged {
  const PasswordChanged({@required String newValue})
      : super(newValue: newValue);
}

class ShowPassword extends _ShowPassword {
  const ShowPassword({@required bool show}) : super(show: show);
}

class ConfirmPasswordChanged extends _PasswordChanged {
  const ConfirmPasswordChanged({@required String newValue})
      : super(newValue: newValue);
}

class ShowConfirmPassword extends _ShowPassword {
  const ShowConfirmPassword({@required bool show}) : super(show: show);
}

class SubmitForm extends PasswordDialogEvent {
  @override
  List<Object> get props => [];

  const SubmitForm();
}

class ValidatePassword extends PasswordDialogEvent {
  final String password;

  @override
  List<Object> get props => [password];

  const ValidatePassword(this.password);
}

part of 'password_dialog_bloc.dart';

class PasswordDialogState extends Equatable {
  final String password;
  final bool isPasswordValid;
  final bool isPasswordDirty;
  final bool showPassword;

  final String confirmPassword;
  final bool isConfirmPasswordValid;
  final bool isConfirmPasswordDirty;
  final bool showConfirmPassword;

  final bool passwordsMatch;
  final bool passwordWasSaved;

//this one can be null, and if it is, it means that the user has been validated
  final bool userIsValid;

  bool get isFormValid =>
      isPasswordValid && isConfirmPasswordValid && passwordsMatch;

  @override
  List<Object> get props => [
        password,
        isPasswordDirty,
        isPasswordValid,
        showPassword,
        confirmPassword,
        isConfirmPasswordValid,
        isConfirmPasswordDirty,
        showConfirmPassword,
        passwordsMatch,
        passwordWasSaved,
        userIsValid,
      ];

  const PasswordDialogState({
    @required this.password,
    @required this.isPasswordValid,
    @required this.isPasswordDirty,
    @required this.showPassword,
    @required this.confirmPassword,
    @required this.isConfirmPasswordValid,
    @required this.isConfirmPasswordDirty,
    @required this.showConfirmPassword,
    @required this.passwordsMatch,
    @required this.passwordWasSaved,
    this.userIsValid,
  });

  factory PasswordDialogState.initial() {
    return const PasswordDialogState(
      password: '',
      isPasswordValid: false,
      isPasswordDirty: false,
      showPassword: false,
      confirmPassword: '',
      isConfirmPasswordValid: false,
      isConfirmPasswordDirty: false,
      showConfirmPassword: false,
      passwordsMatch: true,
      passwordWasSaved: false,
    );
  }

  PasswordDialogState copyWith({
    String password,
    bool isPasswordValid,
    bool isPasswordDirty,
    bool showPassword,
    String confirmPassword,
    bool isConfirmPasswordValid,
    bool isConfirmPasswordDirty,
    bool showConfirmPassword,
    bool passwordsMatch,
    bool passwordWasSaved,
    bool userIsValid,
  }) {
    return PasswordDialogState(
      password: password ?? this.password,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isPasswordDirty: isPasswordDirty ?? this.isPasswordDirty,
      showPassword: showPassword ?? this.showPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isConfirmPasswordValid:
          isConfirmPasswordValid ?? this.isConfirmPasswordValid,
      isConfirmPasswordDirty:
          isConfirmPasswordDirty ?? this.isConfirmPasswordDirty,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      passwordsMatch: passwordsMatch ?? this.passwordsMatch,
      passwordWasSaved: passwordWasSaved ?? this.passwordWasSaved,
      userIsValid: userIsValid ?? this.userIsValid,
    );
  }
}

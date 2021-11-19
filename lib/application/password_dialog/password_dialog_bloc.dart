import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:steel_crypt/steel_crypt.dart';

part 'password_dialog_bloc.freezed.dart';
part 'password_dialog_event.dart';
part 'password_dialog_state.dart';

const _initialState = PasswordDialogState.initial(
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

class PasswordDialogBloc extends Bloc<PasswordDialogEvent, PasswordDialogState> {
  final LoggingService _logger;
  final SecureStorageService _secureStorageService;

  static int maxLength = 10;
  static int minLength = 3;

  PasswordDialogBloc(this._logger, this._secureStorageService) : super(_initialState);

  @override
  Stream<PasswordDialogState> mapEventToState(
    PasswordDialogEvent event,
  ) async* {
    final s = await event.map(
      passwordChanged: (e) async => state.copyWith(
        password: e.newValue,
        isPasswordValid: _isPasswordValid(e.newValue),
        isPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(state.confirmPassword),
        passwordsMatch: _passwordMatches(e.newValue, state.confirmPassword),
      ),
      showPassword: (e) async => state.copyWith(showPassword: e.show),
      confirmPasswordChanged: (e) async => state.copyWith(
        isPasswordValid: _isPasswordValid(state.password),
        confirmPassword: e.newValue,
        isConfirmPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(e.newValue),
        passwordsMatch: _passwordMatches(state.password, e.newValue),
      ),
      showConfirmPassword: (e) async => state.copyWith(showConfirmPassword: e.show),
      submit: (e) async {
        _logger.info(runtimeType, 'Trying to save password...');
        final hash = _getHashedPassword(state.password);
        _secureStorageService.save(SecureResourceType.loginPassword, _secureStorageService.defaultUsername, hash);

        _logger.info(runtimeType, 'Password was successfully saved...');

        return state.copyWith(passwordWasSaved: true);
      },
      validatePassword: (e) async {
        final pass = await _secureStorageService.get(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
        final hasher = HashCrypt(algo: HashAlgo.Blake2b);
        final isValid = hasher.check(plain: e.password, hashed: pass!);
        return state.copyWith(userIsValid: isValid);
      },
    );

    yield s;

    if (event is _Submit) {
      yield _initialState;
    }

    if (event is _ValidatePassword && state.userIsValid == true) {
      yield _initialState;
    }
  }

  bool _isPasswordValid(String password) => !password.isNullOrEmpty(minLength: minLength, maxLength: maxLength);

  bool _passwordMatches(String password, String confirmPassword) =>
      _isPasswordValid(password) && _isPasswordValid(confirmPassword) && password == confirmPassword;

  String _getHashedPassword(String pass) {
    final hasher = HashCrypt(algo: HashAlgo.Blake2b);
    return hasher.hash(inp: pass);
  }
}

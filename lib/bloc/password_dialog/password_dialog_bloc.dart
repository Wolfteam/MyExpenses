import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';

import '../../common/enums/secure_resource_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../services/logging_service.dart';
import '../../services/secure_storage_service.dart';

part 'password_dialog_event.dart';
part 'password_dialog_state.dart';

class PasswordDialogBloc extends Bloc<PasswordDialogEvent, PasswordDialogState> {
  final LoggingService _logger;
  final SecureStorageService _secureStorageService;

  PasswordDialogBloc(this._logger, this._secureStorageService) : super(PasswordDialogState.initial());

  @override
  Stream<PasswordDialogState> mapEventToState(
    PasswordDialogEvent event,
  ) async* {
    if (event is PasswordChanged) {
      yield state.copyWith(
        password: event.newValue,
        isPasswordValid: _isPasswordValid(event.newValue),
        isPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(state.confirmPassword),
        passwordsMatch: _passwordMatches(event.newValue, state.confirmPassword),
      );
    }

    if (event is ShowPassword) {
      yield state.copyWith(showPassword: event.show);
    }

    if (event is ConfirmPasswordChanged) {
      yield state.copyWith(
        isPasswordValid: _isPasswordValid(state.password),
        confirmPassword: event.newValue,
        isConfirmPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(event.newValue),
        passwordsMatch: _passwordMatches(state.password, event.newValue),
      );
    }

    if (event is ShowConfirmPassword) {
      yield state.copyWith(showConfirmPassword: event.show);
    }

    if (event is SubmitForm) {
      _logger.info(runtimeType, 'Trying to save password...');
      final hash = _getHashedPassword(state.password);
      _secureStorageService.save(
        SecureResourceType.loginPassword,
        _secureStorageService.defaultUsername,
        hash,
      );

      _logger.info(runtimeType, 'Password was successfully saved...');

      yield state.copyWith(passwordWasSaved: true);
      yield PasswordDialogState.initial();
    }

    if (event is ValidatePassword) {
      final pass = await _secureStorageService.get(
        SecureResourceType.loginPassword,
        _secureStorageService.defaultUsername,
      );
      final isValid = Password.verify(event.password, pass);
      yield state.copyWith(userIsValid: isValid);

      if (isValid) {
        yield PasswordDialogState.initial();
      }
    }
  }

  bool _isPasswordValid(String password) => !password.isNullOrEmpty(minLength: 3, maxLength: 10);

  bool _passwordMatches(String password, String confirmPassword) =>
      _isPasswordValid(password) && _isPasswordValid(confirmPassword) && password == confirmPassword;

  String _getHashedPassword(String pass) {
    final algorithm = PBKDF2(iterationCount: 100);

    return Password.hash(pass, algorithm);
  }
}

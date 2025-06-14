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

  PasswordDialogBloc(this._logger, this._secureStorageService) : super(_initialState) {
    on<PasswordDialogEventPasswordChanged>((event, emit) {
      final s = state.copyWith(
        password: event.newValue,
        isPasswordValid: _isPasswordValid(event.newValue),
        isPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(state.confirmPassword),
        passwordsMatch: _passwordMatches(event.newValue, state.confirmPassword),
      );
      emit(s);
    });

    on<PasswordDialogEventShowPasswod>((event, emit) {
      final s = state.copyWith(showPassword: event.show);
      emit(s);
    });

    on<PasswordDialogEventConfirmPasswordChanged>((event, emit) {
      final s = state.copyWith(
        isPasswordValid: _isPasswordValid(state.password),
        confirmPassword: event.newValue,
        isConfirmPasswordDirty: true,
        isConfirmPasswordValid: _isPasswordValid(event.newValue),
        passwordsMatch: _passwordMatches(state.password, event.newValue),
      );
      emit(s);
    });

    on<PasswordDialogEventShowConfirmPasswod>((event, emit) {
      final s = state.copyWith(showConfirmPassword: event.show);
      emit(s);
    });

    on<PasswordDialogEventSubmit>((event, emit) {
      _logger.info(runtimeType, 'Trying to save password...');
      final hash = _getHashedPassword(state.password);
      _secureStorageService.save(SecureResourceType.loginPassword, _secureStorageService.defaultUsername, hash);

      _logger.info(runtimeType, 'Password was successfully saved...');
      final s = state.copyWith(passwordWasSaved: true);
      emit(s);
      emit(_initialState);
    });

    on<PasswordDialogEventValidatePassword>((event, emit) async {
      final pass = await _secureStorageService.get(SecureResourceType.loginPassword, _secureStorageService.defaultUsername);
      final hasher = HashCrypt(algo: HashAlgo.Blake2b);
      final isValid = hasher.check(plain: event.password, hashed: pass!);
      final s = state.copyWith(userIsValid: isValid);
      emit(s);

      if (s.userIsValid == true) {
        emit(_initialState);
      }
    });
  }

  bool _isPasswordValid(String password) => !password.isNullOrEmpty(minLength: minLength, maxLength: maxLength);

  bool _passwordMatches(String password, String confirmPassword) =>
      _isPasswordValid(password) && _isPasswordValid(confirmPassword) && password == confirmPassword;

  String _getHashedPassword(String pass) {
    final hasher = HashCrypt(algo: HashAlgo.Blake2b);
    return hasher.hash(inp: pass);
  }
}

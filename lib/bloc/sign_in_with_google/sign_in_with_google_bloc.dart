import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/secure_resource_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/image_utils.dart';
import '../../daos/users_dao.dart';
import '../../services/google_service.dart';
import '../../services/logging_service.dart';
import '../../services/network_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/sync_service.dart';

part 'sign_in_with_google_bloc.freezed.dart';
part 'sign_in_with_google_event.dart';
part 'sign_in_with_google_state.dart';

class SignInWithGoogleBloc extends Bloc<SignInWithGoogleEvent, SignInWithGoogleState> {
  final LoggingService _logger;
  final UsersDao _usersDao;
  final GoogleService _googleService;
  final NetworkService _networkService;
  final SecureStorageService _secureStorageService;
  final SyncService _syncService;

  _InitialState get currentState => state as _InitialState;

  SignInWithGoogleBloc(
    this._logger,
    this._usersDao,
    this._googleService,
    this._networkService,
    this._secureStorageService,
    this._syncService,
  ) : super(const SignInWithGoogleState.loading());

  @override
  Stream<SignInWithGoogleState> mapEventToState(
    SignInWithGoogleEvent event,
  ) async* {
    if (event is _Init) {
      final isInternetAvailable = await _networkService.isInternetAvailable();
      final authUrl = _googleService.getAuthUrl();

      yield SignInWithGoogleState.initial(authUrl: authUrl, isNetworkAvailable: isInternetAvailable);
    }

    if (event is _UrlChanged) {
      final uri = Uri.parse(event.url);
      final code = uri.queryParameters['code'];
      if (!code.isNullEmptyOrWhitespace) {
        yield currentState.copyWith(codeGranted: true);
        yield await _signIn(code!);
        yield const SignInWithGoogleState.loading();
      }
    }
  }

  Future<SignInWithGoogleState> _signIn(String authCode) async {
    _logger.info(runtimeType, '_signIn: Exchanging auth code....');

    try {
      final isSignedIn = await _googleService.exchangeAuthCodeAndSaveCredentials(authCode);
      if (!isSignedIn) {
        _logger.info(
          runtimeType,
          '_signIn: Code exchange failed',
        );
        return currentState.copyWith(flowCompleted: true, codeGranted: false);
      }

      _logger.info(runtimeType, '_signIn: Getting user info...');
      var user = await _googleService.getUserInfo();

      _logger.info(runtimeType, '_signIn: Saving logged user into secure storage...');

      //This needs to be saved here before making any authenticated request
      await Future.wait([
        _secureStorageService.save(
          SecureResourceType.currentUser,
          _secureStorageService.defaultUsername,
          user.email,
        ),
        _secureStorageService.update(
          SecureResourceType.accessTokenData,
          _secureStorageService.defaultUsername,
          true,
          user.email,
        ),
        _secureStorageService.update(
          SecureResourceType.accessTokenExpiricy,
          _secureStorageService.defaultUsername,
          true,
          user.email,
        ),
        _secureStorageService.update(
          SecureResourceType.accessTokenType,
          _secureStorageService.defaultUsername,
          true,
          user.email,
        ),
        _secureStorageService.update(
          SecureResourceType.refreshToken,
          _secureStorageService.defaultUsername,
          true,
          user.email,
        )
      ]);

      if (!user.pictureUrl.isNullEmptyOrWhitespace) {
        _logger.info(runtimeType, '_signIn: Saving user img...');
        final imgPath = await ImageUtils.saveNetworkImage(user.pictureUrl!);
        user = user.copyWith(pictureUrl: imgPath);
      }

      _logger.info(runtimeType, '_signIn: Saving user into db...');
      await _usersDao.saveUser(
        user.googleUserId,
        user.name,
        user.email,
        user.pictureUrl!,
      );

      _logger.info(runtimeType, '_signIn: User was successfully saved...');

      await _syncService.initializeAppFolderAndFiles();

      return currentState.copyWith(flowCompleted: true, codeGranted: false);
    } catch (e, s) {
      _logger.error(runtimeType, '_signIn: Unknown error occurred', e, s);
      return currentState.copyWith(flowCompleted: true, codeGranted: false, anErrorOccurred: true);
    }
  }
}

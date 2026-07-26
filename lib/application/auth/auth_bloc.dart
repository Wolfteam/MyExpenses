import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoggingService _logger;
  final CategoriesDao _categoriesDao;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SecureStorageService _secureStorageService;
  final PathService _pathService;
  final GoogleService _googleService;
  final ImageService _imageService;
  final SyncService _syncService;
  final NetworkService _networkService;
  final SettingsService _settingsService;
  final AppBloc _appBloc;

  AuthBloc(
    this._logger,
    this._categoriesDao,
    this._transactionsDao,
    this._usersDao,
    this._secureStorageService,
    this._pathService,
    this._googleService,
    this._imageService,
    this._syncService,
    this._networkService,
    this._settingsService,
    this._appBloc,
  ) : super(const AuthState.loading()) {
    on<AuthEventInit>(
      (event, emit) => _handler(event, emit, () async {
        final s = await _initialize();
        emit(s);
      }),
    );

    on<AuthEventDeleteAccount>(
      (event, emit) => _handler(event, emit, () async {
        final s = await _deleteUser(event.id, currentState);
        emit(s);
      }),
    );

    on<AuthEventChangeActiveAccount>(
      (event, emit) => _handler(event, emit, () async {
        final s = await _changeActiveUser(event.newActiveUserId, currentState);
        emit(s);
      }),
    );

    on<AuthEventSignIn>(
      (event, emit) => _handler(event, emit, () async {
        emit(currentState.copyWith(signInInProcess: true));

        final isInternetAvailable = await _networkService.isInternetAvailable();
        if (!isInternetAvailable) {
          _logger.warning(runtimeType, '_signInWithGoogle: Network is not available');
          emit(currentState.copyWith(signInInProcess: false, isNetworkAvailable: false));
          return;
        }

        await _googleService.signOut();
        final isSignedIn = await _googleService.signIn();
        if (!isSignedIn) {
          _logger.warning(runtimeType, '_signInWithGoogle: Failed');
          emit(currentState.copyWith(signInInProcess: false, signInResult: false));
          return;
        }

        emit(currentState.copyWith(signInResult: true));
        final s = await _signInWithGoogle(currentState);
        emit(s);
      }),
    );

    on<AuthEventTriggerSync>(
      (event, emit) => _handler(event, emit, () async {
        await _triggerSync();
      }),
    );
  }

  AuthStateInitial get currentState => switch (state) {
    AuthStateLoading() => throw Exception('Invalid state'),
    final AuthStateInitial state => state,
  };

  Future<void> _handler(
    AuthEvent event,
    Emitter<AuthState> emit,
    Future<void> Function() body,
  ) async {
    final isSignIn = event is AuthEventSignIn;
    try {
      await body.call();
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
      if (isSignIn) {
        emit(currentState.copyWith(signInResult: false));
      }
    }

    switch (state) {
      case final AuthStateInitial state:
        emit(
          state.copyWith(
            userWasDeleted: false,
            activeUserChanged: false,
            signInResult: null,
            accountWasAdded: false,
            signInInProcess: false,
          ),
        );
      default:
        break;
    }
  }

  Future<AuthState> _initialize() async {
    _logger.info(runtimeType, '_initialize: Getting all users in db...');
    final users = await _usersDao.getAllUsers();
    final updatedUsers = <UserItem>[];
    for (final user in users) {
      final imgPath = await _pathService.getDynamicUserImg(user.pictureUrl);
      updatedUsers.add(user.copyWith(pictureUrl: imgPath));
    }
    return AuthState.initial(users: updatedUsers, isNetworkAvailable: true);
  }

  Future<AuthState> _deleteUser(
    int id,
    AuthStateInitial state,
  ) async {
    try {
      _logger.info(runtimeType, '_deleteUser: Trying to delete userId = $id');
      _logger.info(runtimeType, '_deleteUser: Deleting all transactions for userId = $id');
      await _transactionsDao.deleteAll(id);

      _logger.info(runtimeType, '_deleteUser: Deleting all categories for userId = $id');
      await _categoriesDao.deleteAll(id);

      _logger.info(runtimeType, '_deleteUser: Deleting userId = $id');
      await _usersDao.deleteUser(id);

      final userImgPath = await _pathService.getUserImgPath(id);
      final dir = Directory(userImgPath);
      if (await dir.exists()) {
        _logger.info(runtimeType, '_deleteUser: Deleting user img path = $userImgPath');
        await dir.delete(recursive: true);
      }

      final username = await _secureStorageService.get(
        SecureResourceType.currentUser,
        _secureStorageService.defaultUsername,
      );
      _logger.info(runtimeType, '_deleteUser: Deleting all items inside the secure storage for user = $username');
      await _secureStorageService.deleteAll(username!);

      final users = await _usersDao.getAllUsers();

      await _updateSecureStorageUsername(users);

      return state.copyWith(users: users, userWasDeleted: true);
    } catch (e, s) {
      _logger.error(runtimeType, '_deleteUser: An error occurred while trying to delete userId = $id', e, s);
      rethrow;
    }
  }

  Future<AuthState> _changeActiveUser(
    int id,
    AuthStateInitial state,
  ) async {
    try {
      //This is to give enough time for the button effect
      await Future.delayed(const Duration(milliseconds: 250));

      _logger.info(runtimeType, '_changeActiveUser: Changing active user to userId = $id');
      await _usersDao.changeActiveUser(id);

      final users = await _usersDao.getAllUsers();

      await _updateSecureStorageUsername(users);

      return state.copyWith(users: users, activeUserChanged: true);
    } catch (e, s) {
      _logger.error(runtimeType, '_changeActiveUser: An error occurred while trying to change active user to userId = $id', e, s);
      rethrow;
    }
  }

  // --- Google-specific methods ---

  Future<AuthState> _signInWithGoogle(AuthStateInitial state) async {
    try {
      _logger.info(runtimeType, '_signInWithGoogle: Getting user info...');
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: true));
      var user = await _googleService.getUserInfo();

      //This needs to be saved here before making any authenticated request
      await _saveCurrentUser(user.email);
      await Future.wait([
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
      ]);

      if (!user.pictureUrl.isNullEmptyOrWhitespace) {
        _logger.info(runtimeType, '_signInWithGoogle: Saving user img...');
        final imgPath = await _imageService.saveNetworkImage(user.pictureUrl!);
        user = user.copyWith(pictureUrl: imgPath);
      }

      _logger.info(runtimeType, '_signInWithGoogle: Saving user into db...');
      await _usersDao.saveUser(user.googleUserId!, user.name, user.email, user.pictureUrl!);

      _logger.info(runtimeType, '_signInWithGoogle: User was successfully saved...');

      await _syncService.initializeAppFolderAndFiles();

      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
      if (state.users.any((el) => el.googleUserId == user.googleUserId)) {
        return state;
      }
      final updatedUsers = [...state.users, user]..sort((x, y) => x.name.compareTo(y.name));
      return state.copyWith(users: updatedUsers, accountWasAdded: true);
    } catch (e, s) {
      _logger.error(runtimeType, '_signInWithGoogle: Unknown error occurred', e, s);
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
      rethrow;
    }
  }

  // --- Sync ---

  Future<void> _triggerSync() async {
    final provider = _settingsService.syncProvider;
    _logger.info(runtimeType, '_triggerSync: Triggering sync for provider = $provider');
    switch (provider) {
      case SyncProviderType.googleDrive:
        await _syncWithGoogleDrive();
      case SyncProviderType.iCloud:
        await _syncWithICloud();
      case SyncProviderType.none:
        _logger.info(runtimeType, '_triggerSync: No provider selected, skipping');
    }
  }

  // --- Google-specific sync ---

  Future<void> _syncWithGoogleDrive() async {
    try {
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: true));

      final signedIn = await _googleService.signInSilently();
      if (signedIn != true) {
        _logger.warning(runtimeType, '_syncWithGoogleDrive: Silent sign-in failed');
        _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
        return;
      }

      await _syncService.downloadAndUpdateFile();
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
    } catch (e, s) {
      _logger.error(runtimeType, '_syncWithGoogleDrive: Error occurred', e, s);
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
      rethrow;
    }
  }

  // --- iCloud-specific sync ---

  Future<void> _syncWithICloud() async {
    try {
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: true));

      final activeUser = await _usersDao.getActiveUser();
      final isFirstSetup =
          activeUser == null || activeUser.googleUserId != null;

      if (isFirstSetup) {
        _logger.info(
          runtimeType,
          '_syncWithICloud: First setup, creating user...',
        );
        final user = await _usersDao.saveICloudUser();
        await _saveCurrentUser(user.email);
        await _syncService.initializeAppFolderAndFiles();
      } else {
        _logger.info(
          runtimeType,
          '_syncWithICloud: Already initialized, syncing...',
        );
        await _syncService.downloadAndUpdateFile();
      }

      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_syncWithICloud: Error occurred',
        e,
        s,
      );
      _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
      rethrow;
    }
  }

  // --- Shared ---

  Future<void> _saveCurrentUser(String email) async {
    _logger.info(runtimeType, '_saveCurrentUser: Saving current user = $email');
    await _secureStorageService.save(
      SecureResourceType.currentUser,
      _secureStorageService.defaultUsername,
      email,
    );
  }

  Future<void> _updateSecureStorageUsername(List<UserItem> users) async {
    if (users.isEmpty) {
      return;
    }

    final currentActiveUser = users.where((u) => u.isActive).first;
    _logger.info(runtimeType, '_updateSecureStorageUsername: Setting secure storage user to = ${currentActiveUser.email}');
    await _secureStorageService.save(
      SecureResourceType.currentUser,
      _secureStorageService.defaultUsername,
      currentActiveUser.email,
    );
  }
}

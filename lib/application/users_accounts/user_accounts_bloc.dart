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

part 'user_accounts_bloc.freezed.dart';
part 'user_accounts_event.dart';
part 'user_accounts_state.dart';

class UserAccountsBloc extends Bloc<UserAccountsEvent, UserAccountsState> {
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
  final AppBloc _appBloc;

  UserAccountsBloc(
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
    this._appBloc,
  ) : super(const UserAccountsState.loading());

  @override
  Stream<UserAccountsState> mapEventToState(UserAccountsEvent event) async* {
    if (event is _SignIn) {
      yield state.maybeMap(
        initial: (state) => state.copyWith(signInInProcess: true),
        orElse: () => state,
      );
    }

    try {
      final s = await event.map(
        init: (_) => _initialize(),
        deleteAccount: (e) => _deleteUser(
          e.id,
          state.maybeMap(initial: (state) => state, orElse: () => throw Exception('Invalid state')),
        ),
        changeActiveAccount: (e) => _changeActiveUser(
          e.newActiveUserId,
          state.maybeMap(initial: (state) => state, orElse: () => throw Exception('Invalid state')),
        ),
        signIn: (_) => _signIn(
          state.maybeMap(initial: (state) => state, orElse: () => throw Exception('Invalid state')),
        ),
      );

      yield s;
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
      yield state.maybeMap(
        initial: (state) => state.copyWith(errorOccurred: true),
        orElse: () => state,
      );
    }

    yield state.maybeMap(
      initial: (state) => state.copyWith(
        userWasDeleted: false,
        activeUserChanged: false,
        errorOccurred: false,
        accountWasAdded: false,
        signInInProcess: false,
      ),
      orElse: () => state,
    );
  }

  Future<UserAccountsState> _initialize() async {
    _logger.info(runtimeType, '_initialize: Getting all users in db...');
    final users = await _usersDao.getAllUsers();
    return UserAccountsState.initial(users: users, isNetworkAvailable: true);
  }

  Future<UserAccountsState> _deleteUser(int id, _InitialState state) async {
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

      final username = await _secureStorageService.get(SecureResourceType.currentUser, _secureStorageService.defaultUsername);
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

  Future<UserAccountsState> _changeActiveUser(int id, _InitialState state) async {
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

  Future<UserAccountsState> _signIn(_InitialState state) async {
    final isInternetAvailable = await _networkService.isInternetAvailable();
    if (!isInternetAvailable) {
      _logger.warning(runtimeType, '_signIn: Network is not available');
      return state.copyWith(errorOccurred: true, isNetworkAvailable: false);
    }

    final isSignedIn = await _googleService.signIn();
    if (!isSignedIn) {
      _logger.warning(runtimeType, '_signIn: Failed');
      return state.copyWith(errorOccurred: true);
    }

    _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: true));
    _logger.info(runtimeType, '_signIn: Getting user info...');
    var user = await _googleService.getUserInfo();

    _logger.info(runtimeType, '_signIn: Saving logged user into secure storage...');

    //This needs to be saved here before making any authenticated request
    await Future.wait([
      _secureStorageService.save(SecureResourceType.currentUser, _secureStorageService.defaultUsername, user.email),
      _secureStorageService.update(SecureResourceType.accessTokenData, _secureStorageService.defaultUsername, true, user.email),
      _secureStorageService.update(SecureResourceType.accessTokenExpiricy, _secureStorageService.defaultUsername, true, user.email),
      _secureStorageService.update(SecureResourceType.accessTokenType, _secureStorageService.defaultUsername, true, user.email),
    ]);

    if (!user.pictureUrl.isNullEmptyOrWhitespace) {
      _logger.info(runtimeType, '_signIn: Saving user img...');
      final imgPath = await _imageService.saveNetworkImage(user.pictureUrl!);
      user = user.copyWith(pictureUrl: imgPath);
    }

    _logger.info(runtimeType, '_signIn: Saving user into db...');
    await _usersDao.saveUser(user.googleUserId, user.name, user.email, user.pictureUrl!);

    _logger.info(runtimeType, '_signIn: User was successfully saved...');

    await _syncService.initializeAppFolderAndFiles();

    _appBloc.add(const AppEvent.bgTaskIsRunning(isRunning: false));
    if (state.users.any((el) => el.googleUserId == user.googleUserId)) {
      return state;
    }
    final updatedUsers = [...state.users, user]..sort((x, y) => x.name.compareTo(y.name));
    return state.copyWith(users: updatedUsers, accountWasAdded: true);
  }

  Future<void> _updateSecureStorageUsername(List<UserItem> users) async {
    if (users.isEmpty) {
      return;
    }

    final currentActiveUser = users.where((u) => u.isActive).first;
    _logger.info(runtimeType, '_updateSecureStorageUsername: Setting secure storage user to = ${currentActiveUser.email}');
    await _secureStorageService.save(SecureResourceType.currentUser, _secureStorageService.defaultUsername, currentActiveUser.email);
  }
}

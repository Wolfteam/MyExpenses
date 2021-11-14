import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
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

  UserAccountsBloc(
    this._logger,
    this._categoriesDao,
    this._transactionsDao,
    this._usersDao,
    this._secureStorageService,
    this._pathService,
  ) : super(UserAccountsState.loading());

  @override
  Stream<UserAccountsState> mapEventToState(UserAccountsEvent event) async* {
    try {
      final s = await event.map(
        init: (_) => _initialize(),
        deleteAccount: (e) => _deleteUser(e.id),
        changeActiveAccount: (e) => _changeActiveUser(e.newActiveUserId),
      );

      yield s;
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
      yield state.copyWith(errorOccurred: true);
    }

    yield state.copyWith(userWasDeleted: false, activeUserChanged: false, errorOccurred: false);
  }

  Future<UserAccountsState> _initialize() async {
    _logger.info(runtimeType, '_initialize: Getting all users in db...');
    final users = await _usersDao.getAllUsers();
    return state.copyWith(users: users);
  }

  Future<UserAccountsState> _deleteUser(int id) async {
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

  Future<UserAccountsState> _changeActiveUser(int id) async {
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

  Future<void> _updateSecureStorageUsername(List<UserItem> users) async {
    if (users.isEmpty) {
      return;
    }

    final currentActiveUser = users.where((u) => u.isActive).first;
    _logger.info(runtimeType, '_updateSecureStorageUsername: Setting secure storage user to = ${currentActiveUser.email}');
    await _secureStorageService.save(SecureResourceType.currentUser, _secureStorageService.defaultUsername, currentActiveUser.email);
  }
}

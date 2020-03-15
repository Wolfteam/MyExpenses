import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../common/enums/secure_resource_type.dart';
import '../../daos/users_dao.dart';
import '../../models/user_item.dart';
import '../../services/logging_service.dart';
import '../../services/secure_storage_service.dart';

part 'user_accounts_event.dart';
part 'user_accounts_state.dart';

class UserAccountsBloc extends Bloc<UserAccountsEvent, UserAccountsState> {
  final LoggingService _logger;
  final UsersDao _usersDao;
  final SecureStorageService _secureStorageService;

  UserAccountsBloc(
    this._logger,
    this._usersDao,
    this._secureStorageService,
  );

  @override
  UserAccountsState get initialState => UserAccountsState.initial();

  @override
  Stream<UserAccountsState> mapEventToState(
    UserAccountsEvent event,
  ) async* {
    if (event is Initialize) {
      yield* _initialize();
    }

    if (event is DeleteAccount) {
      yield* _deleteUser(event.id);
    }

    if (event is ChangeActiveAccount) {
      //This is to give enough time for the button effect
      await Future.delayed(const Duration(milliseconds: 250));
      yield* _changeActiveUser(event.newActiveUserId);
    }
  }

  Stream<UserAccountsState> _initialize() async* {
    _logger.info(runtimeType, '_initialize: Getting all users in db...');
    final users = await _usersDao.getAllUsers();
    yield state.copyWith(users: users);
  }

  Stream<UserAccountsState> _deleteUser(int id) async* {
    try {
      _logger.info(runtimeType, '_deleteUser: Trying to delete userId = $id');
      await _usersDao.deleteUser(id);

      final username = await _secureStorageService.get(
        SecureResourceType.currentUser,
        _secureStorageService.defaultUsername,
      );
      _logger.info(
        runtimeType,
        '_deleteUser: Deleting all items inside the secure storage for user = $username',
      );
      await _secureStorageService.deleteAll(username);

      final users = await _usersDao.getAllUsers();

      await _updateSecureStorageUsername(users);

      final s = state.copyWith(users: users, userWasDeleted: true);
      yield s;
      yield s.copyWith(userWasDeleted: false);
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_deleteUser: An error occurred while trying to delete userId = $id',
        e,
        s,
      );
      yield state.copyWith(errorOcurred: true);
      yield state.copyWith(errorOcurred: false);
    }
  }

  Stream<UserAccountsState> _changeActiveUser(int id) async* {
    try {
      _logger.info(
        runtimeType,
        '_changeActiveUser: Changing active user to userId = $id',
      );
      await _usersDao.changeActiveUser(id);

      final users = await _usersDao.getAllUsers();

      await _updateSecureStorageUsername(users);

      final s = state.copyWith(users: users, activeUserChanged: true);
      yield s;
      yield s.copyWith(activeUserChanged: false);
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_changeActiveUser: An error occurred while trying to change active user to userId = $id',
        e,
        s,
      );
      yield state.copyWith(errorOcurred: true);
      yield state.copyWith(errorOcurred: false);
    }
  }

  Future<void> _updateSecureStorageUsername(List<UserItem> users) async {
    if (users.isEmpty) return;

    final currentActiveUser = users.where((u) => u.isActive).first;
    _logger.info(
      runtimeType,
      '_updateSecureStorageUsername: Setting secure storage user to = ${currentActiveUser.email}',
    );
    await _secureStorageService.save(
      SecureResourceType.currentUser,
      _secureStorageService.defaultUsername,
      currentActiveUser.email,
    );
  }
}

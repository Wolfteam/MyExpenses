import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../daos/users_dao.dart';
import '../../models/user_item.dart';
import '../../services/logging_service.dart';

part 'user_accounts_event.dart';
part 'user_accounts_state.dart';

class UserAccountsBloc extends Bloc<UserAccountsEvent, UserAccountsState> {
  final LoggingService _logger;
  final UsersDao _usersDao;

  UserAccountsBloc(
    this._logger,
    this._usersDao,
  );

  @override
  UserAccountsState get initialState => LoadingState();

  @override
  Stream<UserAccountsState> mapEventToState(
    UserAccountsEvent event,
  ) async* {
    if (event is Initialize) {
      yield* _initialize();
    }
  }

  Stream<UserAccountsState> _initialize() async* {
    _logger.info(runtimeType, '_initialize: Getting all users in db...');
    final users = await _usersDao.getAllUsers();
    yield UsersLoadedState(users);
  }
}

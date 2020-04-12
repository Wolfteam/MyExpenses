import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../common/enums/app_drawer_item_type.dart';
import '../../common/utils/background_utils.dart';
import '../../daos/categories_dao.dart';
import '../../daos/users_dao.dart';
import '../../services/logging_service.dart';

part 'drawer_event.dart';
part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final LoggingService _logger;
  final UsersDao _usersDao;
  final CategoriesDao _categoriesDao;

  @override
  DrawerState get initialState =>
      DrawerState.initial(AppDrawerItemType.transactions);

  DrawerBloc(this._logger, this._usersDao, this._categoriesDao);

  @override
  Stream<DrawerState> mapEventToState(
    DrawerEvent event,
  ) async* {
    if (event is InitializeDrawer) {
      yield* _initialize();
    }

    if (event is DrawerItemSelectionChanged) {
      yield state.copyWith(
        selectedPage: event.selectedPage,
        userSignedOut: false,
      );
    }

    if (event is SignOut) {
      yield* _signOut();
    }
  }

  Stream<DrawerState> _initialize() async* {
    _logger.info(runtimeType, '_initialize: Initializing drawer....');
    final user = await _usersDao.getActiveUser();
    if (user == null) {
      _logger.info(runtimeType, '_initialize: No active user exists on db');
      return;
    }

    _logger.info(runtimeType, '_initialize: User is signed in');

    yield state.copyWith(
      email: user.email,
      fullName: user.name,
      img: user.pictureUrl,
      isUserSignedIn: true,
      userSignedOut: false,
    );
  }

  Stream<DrawerState> _signOut() async* {
    _logger.info(runtimeType, '_signIn: Signing out...');
    await _categoriesDao.onUserSignedOut();
    await _usersDao.deleteAll();
    await BackgroundUtils.cancelSyncTask();
    yield state.copyWith(
      isUserSignedIn: false,
      userSignedOut: true,
    );
  }
}

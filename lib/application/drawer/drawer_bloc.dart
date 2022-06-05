import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/services/services.dart';

part 'drawer_bloc.freezed.dart';
part 'drawer_event.dart';
part 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final LoggingService _logger;
  final UsersDao _usersDao;
  final CategoriesDao _categoriesDao;
  final BackgroundService _backgroundService;
  final GoogleService _googleService;
  final SettingsService _settingsService;

  DrawerBloc(
    this._logger,
    this._usersDao,
    this._categoriesDao,
    this._backgroundService,
    this._googleService,
    this._settingsService,
  ) : super(const DrawerState.loaded(selectedPage: AppDrawerItemType.transactions));

  @override
  Stream<DrawerState> mapEventToState(DrawerEvent event) async* {
    final s = await event.map(
      init: (_) => _initialize(),
      selectedItemChanged: (e) async => state.copyWith(
        selectedPage: e.selectedPage,
        userSignedOut: false,
      ),
      signOut: (_) => _signOut(),
    );

    yield s;
  }

  Future<DrawerState> _initialize() async {
    _logger.info(runtimeType, '_initialize: Initializing drawer....');
    final user = await _usersDao.getActiveUser();
    if (user == null) {
      _logger.info(runtimeType, '_initialize: No active user exists on db');
      return state;
    }

    _logger.info(runtimeType, '_initialize: User is signed in');

    return state.copyWith(
      email: user.email,
      fullName: user.name,
      img: user.pictureUrl,
      isUserSignedIn: true,
      userSignedOut: false,
    );
  }

  Future<DrawerState> _signOut() async {
    _logger.info(runtimeType, '_signOut: Signing out...');
    final signedOut = await _googleService.signOut();
    if (signedOut) {
      _logger.info(runtimeType, '_signOut: Signing out of all the daos...');
      await _categoriesDao.onUserSignedOut();
      await _usersDao.deleteAll();
      await _backgroundService.cancelSyncTask();
      _settingsService.syncInterval = SyncIntervalType.none;
    }

    _logger.info(runtimeType, '_signOut: User was signed out');
    return DrawerState.loaded(
      selectedPage: AppDrawerItemType.transactions,
      isUserSignedIn: !signedOut,
      userSignedOut: signedOut,
    );
  }
}

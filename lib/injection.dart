import 'package:get_it/get_it.dart';

import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'models/entities/database.dart';
import 'services/google_service.dart';
import 'services/logging_service.dart';
import 'services/network_service.dart';
import 'services/secure_storage_service.dart';
import 'services/settings_service.dart';
import 'services/sync_service.dart';

final GetIt getIt = GetIt.instance;

void initInjection() {
  if (!getIt.isRegistered<LoggingService>()) {
    getIt.registerSingleton<LoggingService>(LoggingServiceImpl());
  }

  if (!getIt.isRegistered<SettingsService>()) {
    getIt.registerSingleton<SettingsService>(SettingsServiceImpl(getIt<LoggingService>()));
  }

  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerSingleton<AppDatabase>(AppDatabase());
  }

  if (!getIt.isRegistered<CategoriesDao>()) {
    getIt.registerSingleton<CategoriesDao>(CategoriesDaoImpl(getIt<AppDatabase>()));
  }

  if (!getIt.isRegistered<TransactionsDao>()) {
    getIt.registerSingleton<TransactionsDao>(TransactionsDaoImpl(getIt<AppDatabase>()));
  }

  if (!getIt.isRegistered<UsersDao>()) {
    getIt.registerSingleton<UsersDao>(UsersDaoImpl(getIt<AppDatabase>()));
  }

  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerSingleton<SecureStorageService>(SecureStorageServiceImpl());
  }

  if (!getIt.isRegistered<GoogleService>()) {
    getIt.registerSingleton<GoogleService>(GoogleServiceImpl(getIt<LoggingService>(), getIt<SecureStorageService>()));
  }

  if (!getIt.isRegistered<NetworkService>()) {
    getIt.registerSingleton<NetworkService>(NetworkServiceImpl());
  }

  if (!getIt.isRegistered<SyncService>()) {
    getIt.registerSingleton<SyncService>(SyncServiceImpl(
      getIt<LoggingService>(),
      getIt<TransactionsDao>(),
      getIt<CategoriesDao>(),
      getIt<UsersDao>(),
      getIt<GoogleService>(),
      getIt<SecureStorageService>(),
    ));
  }
}

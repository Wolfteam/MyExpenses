import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:log_4_dart_2/log_4_dart_2.dart';

import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'injection.iconfig.dart';
import 'models/entities/database.dart';
import 'services/logging_service.dart';
import 'services/settings_service.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void initInjection() {
  getIt.registerSingleton(Logger());
  getIt.registerSingleton<LoggingService>(LoggingServiceImpl(getIt<Logger>()));
  getIt.registerSingleton<SettingsService>(
    SettingsServiceImpl(getIt<LoggingService>()),
  );
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<CategoriesDao>(
    CategoriesDaoImpl(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<TransactionsDao>(
    TransactionsDaoImpl(getIt<AppDatabase>()),
  );
  getIt.registerSingleton<UsersDao>(UsersDaoImpl(getIt<AppDatabase>()));
  $initGetIt(getIt);
}

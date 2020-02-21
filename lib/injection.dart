import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'injection.iconfig.dart';
import 'models/entities/database.dart';

final GetIt getIt = GetIt.instance;

@injectableInit
void configure() {
  getIt.registerSingleton<AppDatabase>(AppDatabase());
  getIt.registerSingleton<CategoriesDao>(
      CategoriesDaoImpl(getIt<AppDatabase>()));
  getIt.registerSingleton<TransactionsDao>(
      TransactionsDaoImpl(getIt<AppDatabase>()));
  getIt.registerSingleton<UsersDao>(
      UsersDaoImpl(getIt<AppDatabase>()));
  $initGetIt(getIt);
}

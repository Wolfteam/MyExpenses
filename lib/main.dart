import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/app_widget.dart';
import 'package:provider/provider.dart';

import 'bloc/app/app_bloc.dart' as app_bloc;
import 'bloc/categories_list/categories_list_bloc.dart';
import 'bloc/category_form/category_form_bloc.dart';
import 'bloc/category_icon/category_icon_bloc.dart';
import 'bloc/chart_details/chart_details_bloc.dart';
import 'bloc/charts/charts_bloc.dart';
import 'bloc/currency/currency_bloc.dart';
import 'bloc/drawer/drawer_bloc.dart';
import 'bloc/estimates/estimates_bloc.dart';
import 'bloc/main_tab/main_tab_bloc.dart';
import 'bloc/password_dialog/password_dialog_bloc.dart';
import 'bloc/reports/reports_bloc.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import 'bloc/splash_screen/splash_screen_bloc.dart';
import 'bloc/transaction_form/transaction_form_bloc.dart';
import 'bloc/transactions/transactions_bloc.dart';
import 'bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import 'bloc/transactions_per_month/transactions_per_month_bloc.dart';
import 'bloc/users_accounts/user_accounts_bloc.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'injection.dart';
import 'models/current_selected_category.dart';
import 'services/google_service.dart';
import 'services/logging_service.dart';
import 'services/network_service.dart';
import 'services/secure_storage_service.dart';
import 'services/settings_service.dart';
import 'services/sync_service.dart';
import 'telemetry.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initInjection();
  await initTelemetry();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CurrentSelectedCategory()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) {
              final settingsService = getIt<SettingsService>();
              return CurrencyBloc(settingsService);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final categoriesDao = getIt<CategoriesDao>();
              final usersDao = getIt<UsersDao>();
              return IncomesCategoriesBloc(logger, categoriesDao, usersDao);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final categoriesDao = getIt<CategoriesDao>();
              final usersDao = getIt<UsersDao>();
              return ExpensesCategoriesBloc(logger, categoriesDao, usersDao);
            },
          ),
          BlocProvider(create: (ctx) => TransactionsLast7DaysBloc()),
          BlocProvider(create: (ctx) => TransactionsPerMonthBloc(getIt<SettingsService>())),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final transactionsDao = getIt<TransactionsDao>();
              final usersDao = getIt<UsersDao>();
              final settingsService = getIt<SettingsService>();
              return TransactionsBloc(
                logger,
                transactionsDao,
                usersDao,
                settingsService,
                ctx.read<TransactionsPerMonthBloc>(),
                ctx.read<TransactionsLast7DaysBloc>(),
              );
            },
          ),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final transactionsDao = getIt<TransactionsDao>();
            final settingsService = getIt<SettingsService>();
            final usersDao = getIt<UsersDao>();
            return TransactionFormBloc(
              logger,
              transactionsDao,
              usersDao,
              settingsService,
            );
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final usersDao = getIt<UsersDao>();
            final categoriesDao = getIt<CategoriesDao>();
            return DrawerBloc(logger, usersDao, categoriesDao);
          }),
          BlocProvider(create: (ctx) {
            return MainTabBloc();
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            final drawerBloc = ctx.read<DrawerBloc>();
            return app_bloc.AppBloc(logger, settingsService, drawerBloc);
          }),
          BlocProvider(create: (ctx) {
            final settingsService = getIt<SettingsService>();
            final secureStorage = getIt<SecureStorageService>();
            final usersDao = getIt<UsersDao>();
            return SettingsBloc(settingsService, secureStorage, usersDao, ctx.read<app_bloc.AppBloc>());
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final categoriesDao = getIt<CategoriesDao>();
            final usersDao = getIt<UsersDao>();
            return CategoryFormBloc(logger, categoriesDao, usersDao);
          }),
          BlocProvider(create: (ctx) => CategoryIconBloc()),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final transactionsDao = getIt<TransactionsDao>();
            final usersDao = getIt<UsersDao>();
            final settingsService = getIt<SettingsService>();
            return ChartsBloc(
              logger,
              transactionsDao,
              usersDao,
              settingsService,
            );
          }),
          BlocProvider(create: (ctx) => ChartDetailsBloc()),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final transactionsDao = getIt<TransactionsDao>();
              final usersDao = getIt<UsersDao>();
              final currencyBloc = ctx.read<CurrencyBloc>();
              return ReportsBloc(
                logger,
                transactionsDao,
                usersDao,
                currencyBloc,
              );
            },
          ),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final secureStorage = getIt<SecureStorageService>();
            return PasswordDialogBloc(logger, secureStorage);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final categoriesDao = getIt<CategoriesDao>();
            final transactionsDao = getIt<TransactionsDao>();
            final usersDao = getIt<UsersDao>();
            final secureStorage = getIt<SecureStorageService>();
            return UserAccountsBloc(
              logger,
              categoriesDao,
              transactionsDao,
              usersDao,
              secureStorage,
            );
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final googleService = getIt<GoogleService>();
            final usersDao = getIt<UsersDao>();
            final networkService = getIt<NetworkService>();
            final secureStorage = getIt<SecureStorageService>();
            final syncService = getIt<SyncService>();
            return SignInWithGoogleBloc(
              logger,
              usersDao,
              googleService,
              networkService,
              secureStorage,
              syncService,
            );
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            final usersDao = getIt<UsersDao>();
            final transactionsDao = getIt<TransactionsDao>();
            return EstimatesBloc(logger, settingsService, usersDao, transactionsDao);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            final usersDao = getIt<UsersDao>();
            final transactionsDao = getIt<TransactionsDao>();
            return SearchBloc(logger, transactionsDao, usersDao, settingsService);
          }),
          BlocProvider(create: (ctx) {
            final settingsService = getIt<SettingsService>();
            return SplashScreenBloc(settingsService)..add(const SplashScreenEvent.init());
          }),
        ],
        child: AppWidget(),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/injection.dart';
import 'package:my_expenses/presentation/app_widget.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
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
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final usersDao = getIt<UsersDao>();
              final categoriesDao = getIt<CategoriesDao>();
              final bgService = getIt<BackgroundService>();
              final googleService = getIt<GoogleService>();
              final settingsService = getIt<SettingsService>();
              return DrawerBloc(logger, usersDao, categoriesDao, bgService, googleService, settingsService)..add(const DrawerEvent.init());
            },
          ),
          BlocProvider(
            create: (ctx) {
              return MainTabBloc();
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final settingsService = getIt<SettingsService>();
              final drawerBloc = ctx.read<DrawerBloc>();
              final bgService = getIt<BackgroundService>();
              final deviceInfoService = getIt<DeviceInfoService>();
              final googleService = getIt<GoogleService>();
              return AppBloc(logger, settingsService, drawerBloc, bgService, deviceInfoService, googleService);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final settingsService = getIt<SettingsService>();
              final secureStorage = getIt<SecureStorageService>();
              final bgService = getIt<BackgroundService>();
              final deviceInfoService = getIt<DeviceInfoService>();
              return SettingsBloc(settingsService, secureStorage, bgService, deviceInfoService, getIt<UsersDao>(), ctx.read<AppBloc>())
                ..add(const SettingsEvent.load());
            },
          ),
          BlocProvider(create: (ctx) => CategoryIconBloc()),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final transactionsDao = getIt<TransactionsDao>();
              final usersDao = getIt<UsersDao>();
              final settingsService = getIt<SettingsService>();
              final now = DateTime.now();
              return ChartsBloc(logger, transactionsDao, usersDao, settingsService)
                ..add(ChartsEvent.loadChart(selectedMonthDate: now, selectedYear: now.year));
            },
          ),
        ],
        child: AppWidget(),
      ),
    );
  }
}

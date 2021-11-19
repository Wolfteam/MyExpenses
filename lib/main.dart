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
              final transactionsDao = getIt<TransactionsDao>();
              final settingsService = getIt<SettingsService>();
              final usersDao = getIt<UsersDao>();
              final pathService = getIt<PathService>();
              return TransactionFormBloc(logger, transactionsDao, usersDao, settingsService, pathService);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final usersDao = getIt<UsersDao>();
              final categoriesDao = getIt<CategoriesDao>();
              final bgService = getIt<BackgroundService>();
              return DrawerBloc(logger, usersDao, categoriesDao, bgService)..add(const DrawerEvent.init());
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
              return AppBloc(logger, settingsService, drawerBloc, bgService, deviceInfoService);
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
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final transactionsDao = getIt<TransactionsDao>();
              final usersDao = getIt<UsersDao>();
              final currencyBloc = ctx.read<CurrencyBloc>();
              final pathService = getIt<PathService>();
              final notificationService = getIt<NotificationService>();
              final deviceInfoService = getIt<DeviceInfoService>();
              return ReportsBloc(logger, transactionsDao, pathService, notificationService, deviceInfoService, usersDao, currencyBloc);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final googleService = getIt<GoogleService>();
              final usersDao = getIt<UsersDao>();
              final networkService = getIt<NetworkService>();
              final secureStorage = getIt<SecureStorageService>();
              final syncService = getIt<SyncService>();
              final imgService = getIt<ImageService>();
              return SignInWithGoogleBloc(logger, usersDao, googleService, networkService, secureStorage, syncService, imgService);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final settingsService = getIt<SettingsService>();
              return SplashScreenBloc(settingsService)..add(const SplashScreenEvent.init());
            },
          ),
        ],
        child: AppWidget(),
      ),
    );
  }
}

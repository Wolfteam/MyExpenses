import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'bloc/app/app_bloc.dart' as app_bloc;
import 'bloc/categories_list/categories_list_bloc.dart';
import 'bloc/category_form/category_form_bloc.dart';
import 'bloc/category_icon/category_icon_bloc.dart';
import 'bloc/chart_details/chart_details_bloc.dart';
import 'bloc/charts/charts_bloc.dart';
import 'bloc/drawer/drawer_bloc.dart';
import 'bloc/password_dialog/password_dialog_bloc.dart';
import 'bloc/reports/reports_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import 'bloc/transaction_form/transaction_form_bloc.dart';
import 'bloc/transactions/transactions_bloc.dart';
import 'bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import 'bloc/users_accounts/user_accounts_bloc.dart';
import 'common/utils/notification_utils.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'generated/i18n.dart';
import 'injection.dart';
import 'logger.dart';
import 'models/current_selected_category.dart';
import 'services/google_service.dart';
import 'services/logging_service.dart';
import 'services/network_service.dart';
import 'services/secure_storage_service.dart';
import 'services/settings_service.dart';
import 'telemetry.dart';
import 'ui/pages/main_page.dart';
import 'ui/widgets/splash_screen.dart';

Future main() async {
  initInjection();
  await setupLogging();
  await initTelemetry();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final i18n = I18n.delegate;

  @override
  void initState() {
    super.initState();
    I18n.onLocaleChanged = _onLocaleChange;
  }

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
              final logger = getIt<LoggingService>();
              final categoriesDao = getIt<CategoriesDao>();
              return IncomesCategoriesBloc(logger, categoriesDao);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final categoriesDao = getIt<CategoriesDao>();
              return ExpensesCategoriesBloc(logger, categoriesDao);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final logger = getIt<LoggingService>();
              final transactionsDao = getIt<TransactionsDao>();
              final settingsService = getIt<SettingsService>();
              return TransactionsBloc(logger, transactionsDao, settingsService);
            },
          ),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final transactionsDao = getIt<TransactionsDao>();
            final settingsService = getIt<SettingsService>();
            return TransactionFormBloc(
                logger, transactionsDao, settingsService);
          }),
          BlocProvider(create: (ctx) => TransactionsLast7DaysBloc()),
          BlocProvider(create: (ctx) {
            final settingsService = getIt<SettingsService>();
            return SettingsBloc(settingsService);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            return app_bloc.AppBloc(logger, settingsService);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final usersDao = getIt<UsersDao>();
            return DrawerBloc(logger, usersDao);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final categoriesDao = getIt<CategoriesDao>();
            return CategoryFormBloc(logger, categoriesDao);
          }),
          BlocProvider(create: (ctx) => CategoryIconBloc()),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final transactionsDao = getIt<TransactionsDao>();
            final settingsService = getIt<SettingsService>();
            return ChartsBloc(logger, transactionsDao, settingsService);
          }),
          BlocProvider(create: (ctx) => ChartDetailsBloc()),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final transactionsDao = getIt<TransactionsDao>();
            return ReportsBloc(logger, transactionsDao);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            return PasswordDialogBloc(logger, settingsService);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final usersDao = getIt<UsersDao>();
            final secureStorage = getIt<SecureStorageService>();
            return UserAccountsBloc(logger, usersDao, secureStorage);
          }),
          BlocProvider(create: (ctx) {
            final logger = getIt<LoggingService>();
            final googleService = getIt<GoogleService>();
            final usersDao = getIt<UsersDao>();
            final networkService = getIt<NetworkService>();
            final secureStorage = getIt<SecureStorageService>();
            return SignInWithGoogleBloc(
              logger,
              usersDao,
              googleService,
              networkService,
              secureStorage,
            );
          }),
        ],
        child: BlocConsumer<app_bloc.AppBloc, app_bloc.AppState>(
          listener: (ctx, state) async {
            if (state is app_bloc.AppInitializedState) {
              await setupNotifications(
                onIosReceiveLocalNotification: _onDidReceiveLocalNotification,
                onSelectNotification: _onSelectNotification,
              );

              ctx.bloc<DrawerBloc>().add(const InitializeDrawer());
            }
          },
          builder: (ctx, state) => _buildApp(ctx, state),
        ),
      ),
    );
  }

//TODO: SHOW THE RECURRING DATE IN THE RECURRING TRANSACTIONS
//TODO: USE SUPER ENUM
//TODO: USE BLOC TO BLOC COMMUNICATION
  Widget _buildApp(BuildContext ctx, app_bloc.AppState state) {
    final delegates = <LocalizationsDelegate>[
      // A class which loads the translations from JSON files
      i18n,
      // Built-in localization of basic text for Material widgets
      GlobalMaterialLocalizations.delegate,
      // Built-in localization for text direction LTR/RTL
      GlobalWidgetsLocalizations.delegate,
      // Built-in localization of basic text for Cupertino widgets
      GlobalCupertinoLocalizations.delegate,
    ];

    if (state is app_bloc.AppInitializedState) {
      return MaterialApp(
        theme: state.theme,
        home: MainPage(),
        localizationsDelegates: delegates,
        supportedLocales: i18n.supportedLocales,
        localeResolutionCallback: i18n.resolution(
          fallback: i18n.supportedLocales.first,
        ),
      );
    }

//i need to set the theme here, otherwise, the theme change will flash
    ThemeData theme;
    if (state is app_bloc.AuthenticationState) {
      theme = state.theme;
    }

    return MaterialApp(
      home: SplashScreen(),
      theme: theme,
      localizationsDelegates: delegates,
      supportedLocales: i18n.supportedLocales,
      localeResolutionCallback: i18n.resolution(
        fallback: i18n.supportedLocales.first,
      ),
    );
  }

  void _onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }

  Future _onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    final i18n = I18n.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(i18n.ok),
          )
        ],
      ),
    );
  }

  Future<bool> _onSelectNotification(String payload) async {
    OpenFile.open(payload);
    return true;
  }
}

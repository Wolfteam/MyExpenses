import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'bloc/password_dialog/password_dialog_bloc.dart';
import 'bloc/reports/reports_bloc.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/sign_in_with_google/sign_in_with_google_bloc.dart';
import 'bloc/transaction_form/transaction_form_bloc.dart';
import 'bloc/transactions/transactions_bloc.dart';
import 'bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import 'bloc/transactions_per_month/transactions_per_month_bloc.dart';
import 'bloc/users_accounts/user_accounts_bloc.dart';
import 'common/enums/notification_type.dart';
import 'common/extensions/string_extensions.dart';
import 'common/utils/i18n_utils.dart';
import 'common/utils/notification_utils.dart';
import 'common/utils/toast_utils.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/users_dao.dart';
import 'injection.dart';
import 'models/app_notification.dart';
import 'models/current_selected_category.dart';
import 'services/google_service.dart';
import 'services/logging_service.dart';
import 'services/network_service.dart';
import 'services/secure_storage_service.dart';
import 'services/settings_service.dart';
import 'services/sync_service.dart';
import 'telemetry.dart';
import 'ui/pages/add_edit_transasctiton_page.dart';
import 'ui/pages/main_page.dart';
import 'ui/widgets/loading.dart';
import 'ui/widgets/splash_screen.dart';

Future main() async {
  initInjection();
  await initTelemetry();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final i18n = S.delegate;

  @override
  void initState() {
    super.initState();
    // S.onLocaleChanged = _onLocaleChange;
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
        ],
        child: BlocConsumer<app_bloc.AppBloc, app_bloc.AppState>(
          listener: (ctx, state) async {
            await state.maybeMap(
              loaded: (state) async {
                await setupNotifications(
                  onIosReceiveLocalNotification: _onDidReceiveLocalNotification,
                  onSelectNotification: _onSelectNotification,
                );

                ctx.read<DrawerBloc>().add(const DrawerEvent.init());
              },
              orElse: () async {},
            );
          },
          builder: (ctx, state) => _buildApp(ctx, state),
        ),
      ),
    );
  }

  Widget _buildApp(BuildContext ctx, app_bloc.AppState state) {
    final delegates = <LocalizationsDelegate>[
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    return state.map(
      loaded: (state) {
        final locale = Locale(state.language.code, state.language.countryCode);
        if (state.bgTaskIsRunning) {
          return MaterialApp(
            home: Loading(),
            theme: state.theme,
            //Without this, the lang won't be reloaded
            locale: locale,
            localizationsDelegates: delegates,
            supportedLocales: S.delegate.supportedLocales,
          );
        }
        return MaterialApp(
          theme: state.theme,
          home: MainPage(),
          //Without this, the lang won't be reloaded
          locale: locale,
          localizationsDelegates: delegates,
          supportedLocales: S.delegate.supportedLocales,
        );
      },
      auth: (state) {
        final locale = Locale(state.language.code, state.language.countryCode);
        final theme = state.maybeMap(auth: (state) => state.theme, orElse: () => null);
        return MaterialApp(
          home: SplashScreen(),
          theme: theme,
          //Without this, the lang won't be reloaded
          locale: locale,
          localizationsDelegates: delegates,
          supportedLocales: S.delegate.supportedLocales,
        );
      },
      loading: (state) {
        final theme = state.maybeMap(auth: (state) => state.theme, orElse: () => null);
        return MaterialApp(
          home: SplashScreen(),
          theme: theme,
          localizationsDelegates: delegates,
          supportedLocales: S.delegate.supportedLocales,
        );
      },
    );
  }

  Future<dynamic> _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    final i18n = S.of(context);
    return showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title!),
        content: Text(body!),
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

  Future<void> _onSelectNotification(String? json) async {
    if (json.isNullEmptyOrWhitespace) {
      return;
    }

    final notification = AppNotification.fromJson(jsonDecode(json!) as Map<String, dynamic>);

    switch (notification.type) {
      case NotificationType.openPdf:
        //open_file crashes while asking for permissions...
        //that's why whe ask for them before opening the file
        final granted = await Permission.storage.isGranted;
        if (!granted) {
          final result = await Permission.storage.request();
          if (!result.isGranted) {
            final settingsService = getIt<SettingsService>();
            final i18n = await getI18n(settingsService.language);
            ToastUtils.showWarningToast(context, i18n.openFilePermissionRequestFailedMsg);
            return;
          }
        }
        final file = File(notification.payload!);
        if (await file.exists()) {
          await OpenFile.open(file.path);
        }
        break;
      case NotificationType.openTransactionDetails:
        final transDao = getIt<TransactionsDao>();
        final transaction = await transDao.getTransaction(int.parse(notification.payload!));
        final route = AddEditTransactionPage.editRoute(transaction, context);
        await Navigator.push(context, route);
        await route.completed;
        context.read<TransactionFormBloc>().add(const TransactionFormEvent.close());
        break;
      case NotificationType.msg:
        break;
    }
  }
}

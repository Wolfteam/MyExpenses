import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import './ui/pages/main_page.dart';
import 'bloc/app/app_bloc.dart' as app_bloc;
import 'bloc/categories_list/categories_list_bloc.dart';
import 'bloc/drawer/drawer_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/transaction_form/transaction_form_bloc.dart';
import 'bloc/transactions/transactions_bloc.dart';
import 'bloc/transactions_last_7_days/transactions_last_7_days_bloc.dart';
import 'generated/i18n.dart';
import 'models/current_selected_category.dart';
import 'models/entities/database.dart';
import 'services/settings_service.dart';

void main() {
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
        Provider(create: (ctx) => AppDatabase()),
        ChangeNotifierProvider(create: (ctx) => CurrentSelectedCategory()),
        Provider(create: (ctx) => SettingsServiceImpl()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) {
              final db = Provider.of<AppDatabase>(ctx, listen: false);
              return IncomesCategoriesBloc(db);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final db = Provider.of<AppDatabase>(ctx, listen: false);
              return ExpensesCategoriesBloc(db);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final db = Provider.of<AppDatabase>(ctx, listen: false);
              return TransactionsBloc(db: db);
            },
          ),
          BlocProvider(create: (ctx) {
            final db = Provider.of<AppDatabase>(ctx, listen: false);
            return TransactionFormBloc(db);
          }),
          BlocProvider(create: (ctx) => TransactionsLast7DaysBloc()),
          BlocProvider(create: (ctx) {
            final settingsService = Provider.of<SettingsServiceImpl>(
              ctx,
              listen: false,
            );
            return SettingsBloc(settingsService);
          }),
          BlocProvider(create: (ctx) {
            final settingsService = Provider.of<SettingsServiceImpl>(
              ctx,
              listen: false,
            );
            return app_bloc.AppBloc(settingsService);
          }),
          BlocProvider(create: (ctx) => DrawerBloc()),
        ],
        child: BlocBuilder<app_bloc.AppBloc, app_bloc.AppState>(
          builder: (ctx, state) => _buildApp(ctx, state),
        ),
      ),
    );
  }

  Widget _buildApp(BuildContext ctx, app_bloc.AppState state) {
    if (state is app_bloc.AppInitializedState) {
      return MaterialApp(
        theme: state.theme,
        home: MainPage(),
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          i18n,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
          // Built-in localization of basic text for Cupertino widgets
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: i18n.supportedLocales,
        localeResolutionCallback: i18n.resolution(
          fallback: i18n.supportedLocales.first,
        ),
      );
    }
    ctx.bloc<app_bloc.AppBloc>().add(const app_bloc.InitializeApp());

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }
}

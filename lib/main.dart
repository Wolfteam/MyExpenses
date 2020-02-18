import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'bloc/bloc.dart';
import 'generated/i18n.dart';
import 'models/current_selected_category.dart';
import 'models/entities/database.dart';
import 'pages/main_page.dart';
import 'services/settings_service.dart';

//TODO: USE THE CONST KEYWORD!!!
//TODO: MOVE THE ASSETS TO A COMMON CLASS
//
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
            return SettingsBloc(SettingsServiceImpl());
          }),
        ],
        child: MaterialApp(
          theme: ThemeData(
              primarySwatch: Colors.purple, accentColor: Colors.amber),
          home: HomePage(),
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
        ),
      ),
    );
  }

  void _onLocaleChange(Locale locale) {
    setState(() {
      I18n.locale = locale;
    });
  }
}

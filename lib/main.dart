import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './bloc/bloc.dart';
import './models/current_selected_category.dart';
import './models/entities/database.dart';
import 'pages/main_page.dart';

//TODO: USE THE CONST KEYWORD!!!
//TODO: MOVE THE ASSETS TO A COMMON CLASS
//
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        ],
        child: MaterialApp(
          title: 'My Expenses',
          theme: ThemeData(
              primarySwatch: Colors.purple, accentColor: Colors.amber),
          home: HomePage(),
        ),
      ),
    );
  }
}

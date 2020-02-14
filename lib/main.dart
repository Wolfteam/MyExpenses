import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import './bloc/bloc.dart';
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
    return Provider(
      create: (ctx) => AppDatabase(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) {
              final db = Provider.of<AppDatabase>(ctx, listen: false);
              return CategoriesListBloc(db);
            },
          ),
          BlocProvider(
            create: (ctx) {
              final db = Provider.of<AppDatabase>(ctx, listen: false);
              return TransactionsBloc(db: db);
            },
          ),
          BlocProvider(create: (ctx) => TransactionFormBloc()),
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

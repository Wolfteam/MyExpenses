import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/drawer/drawer_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';

class BlocUtils {
  static void userChanged(BuildContext ctx) {
    debugPrint(
      'User changed, raising corresponding events for transactions, charts, incomes, expenses and drawer bloc',
    );
    final now = DateTime.now();
    ctx.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: now));
    ctx.bloc<ChartsBloc>().add(LoadChart(now));
    ctx
        .bloc<IncomesCategoriesBloc>()
        .add(const GetCategories(loadIncomes: true));
    ctx
        .bloc<ExpensesCategoriesBloc>()
        .add(const GetCategories(loadIncomes: false));
    ctx.bloc<DrawerBloc>().add(const InitializeDrawer());
  }
}

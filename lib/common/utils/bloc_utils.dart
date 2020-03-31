import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/drawer/drawer_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';

class BlocUtils {
  static void raiseCommonBlocEvents(
    BuildContext ctx, {
    bool reloadTransactions = true,
    bool reloadCharts = true,
    bool reloadCategories = true,
    bool reloadDrawer = true,
  }) {
    debugPrint(
      'Raising corresponding events for transactions, charts, incomes, expenses and drawer bloc',
    );
    final now = DateTime.now();
    if (reloadTransactions) {
      final transBloc = ctx.bloc<TransactionsBloc>();
      if (transBloc.currentState.showParentTransactions) {
        ctx.bloc<TransactionsBloc>().add(const GetAllParentTransactions());
      } else {
        ctx.bloc<TransactionsBloc>().add(GetTransactions(inThisDate: now));
      }
    }

    if (reloadCharts) {
      ctx.bloc<ChartsBloc>().add(LoadChart(now));
    }

    if (reloadCategories) {
      ctx
          .bloc<IncomesCategoriesBloc>()
          .add(const GetCategories(loadIncomes: true));
      ctx
          .bloc<ExpensesCategoriesBloc>()
          .add(const GetCategories(loadIncomes: false));
    }

    if (reloadDrawer) {
      ctx.bloc<DrawerBloc>().add(const InitializeDrawer());
    }
  }
}

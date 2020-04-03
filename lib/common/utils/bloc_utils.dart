import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/categories_list/categories_list_bloc.dart';
import '../../bloc/charts/charts_bloc.dart';
import '../../bloc/drawer/drawer_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../../bloc/transactions/transactions_bloc.dart';

class BlocUtils {
  static void raiseAllCommonBlocEvents(BuildContext ctx) {
    raiseCommonBlocEvents(
      ctx,
      reloadCategories: true,
      reloadCharts: true,
      reloadDrawer: true,
      reloadSettings: true,
      reloadTransactions: true,
    );
  }

  static void raiseCommonBlocEvents(
    BuildContext ctx, {
    bool reloadTransactions = false,
    bool reloadCharts = false,
    bool reloadCategories = false,
    bool reloadDrawer = false,
    bool reloadSettings = false,
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

    if (reloadSettings) {
      ctx.bloc<SettingsBloc>().add(const LoadSettings());
    }
  }
}

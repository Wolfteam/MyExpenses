import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_expenses/application/bloc.dart';

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
    debugPrint('Raising corresponding events for transactions, charts, incomes, expenses and drawer bloc');

    final now = DateTime.now();
    if (reloadTransactions) {
      final transBloc = ctx.read<TransactionsBloc>();
      if (transBloc.currentState.showParentTransactions) {
        ctx.read<TransactionsBloc>().add(const TransactionsEvent.loadRecurringTransactions());
      } else {
        ctx.read<TransactionsBloc>().add(TransactionsEvent.loadTransactions(inThisDate: now));
      }
    }

    if (reloadCharts) {
      ctx.read<ChartsBloc>().add(ChartsEvent.loadChart(selectedMonthDate: now, selectedYear: now.year));
    }

    if (reloadCategories) {
      ctx.read<IncomesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: true));
      ctx.read<ExpensesCategoriesBloc>().add(const CategoriesListEvent.getCategories(loadIncomes: false));
    }

    if (reloadDrawer) {
      ctx.read<DrawerBloc>().add(const DrawerEvent.init());
    }

    if (reloadSettings) {
      ctx.read<SettingsBloc>().add(const SettingsEvent.load());
    }
  }
}

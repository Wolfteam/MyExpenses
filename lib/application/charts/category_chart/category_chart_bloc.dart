import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'category_chart_bloc.freezed.dart';
part 'category_chart_event.dart';
part 'category_chart_state.dart';

class CategoryChartBloc extends Bloc<CategoryChartEvent, CategoryChartState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;

  CategoryChartBloc(this._logger, this._transactionsDao, this._usersDao)
    : super(const CategoryChartState.loaded(loaded: false, categories: [])) {
    on<CategoryChartEventLoad>((event, emit) async {
      final user = await _usersDao.getActiveUser();
      _logger.info(runtimeType, 'load: from=${event.from} to=${event.to}');
      final transactions = await _transactionsDao.getAllTransactions(user?.id, event.from, event.to);
      emit(CategoryChartState.loaded(loaded: true, categories: _buildCategories(transactions)));
    });
  }

  List<CategoryChartItem> _buildCategories(List<TransactionItem> transactions) {
    final expenseTransactions = transactions.where((t) => !t.category.isAnIncome).toList();
    final grouped = <String, double>{};
    final categoryMeta = <String, (Color, IconData?, bool)>{};

    for (final t in expenseTransactions) {
      final key = t.category.name;
      grouped[key] = TransactionUtils.roundDouble((grouped[key] ?? 0) + t.amount.abs());
      categoryMeta.putIfAbsent(key, () => (t.category.iconColor ?? Colors.grey, t.category.icon, t.category.isAnIncome));
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return [];
    }

    return grouped.entries.sortedByCompare((e) => e.value, (a, b) => b.compareTo(a)).map((e) {
      final (color, icon, isAnIncome) = categoryMeta[e.key]!;
      return CategoryChartItem(
        categoryName: e.key,
        total: e.value,
        percentage: TransactionUtils.roundDouble((e.value / total) * 100),
        color: color,
        isAnIncome: isAnIncome,
        icon: icon,
      );
    }).toList();
  }
}

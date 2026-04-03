import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'charts_bloc.freezed.dart';
part 'charts_event.dart';
part 'charts_state.dart';

const _initialState = ChartsState.loaded(
  loaded: false,
  selectedPeriod: ChartPeriodType.last30days,
  totalIncome: 0,
  totalExpense: 0,
  balance: 0,
  topCategories: [],
  monthlyPoints: [],
);

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final PaymentMethodsDao _paymentMethodsDao;

  ChartsStateLoaded get currentState => state as ChartsStateLoaded;

  ChartsBloc(this._logger, this._transactionsDao, this._usersDao, this._paymentMethodsDao) : super(_initialState) {
    on<ChartsEventInit>((event, emit) async {
      final s = await _load(ChartPeriodType.last30days);
      emit(s);
    });

    on<ChartsEventPeriodChanged>((event, emit) async {
      final s = await _load(
        event.period,
        customStart: currentState.customStart,
        customEnd: currentState.customEnd,
      );
      emit(s);
    });

    on<ChartsEventCustomRangeSelected>((event, emit) async {
      final s = await _load(ChartPeriodType.custom, customStart: event.start, customEnd: event.end);
      emit(s);
    });
  }

  (DateTime, DateTime) getDateRange() {
    return _computeDateRange(
      currentState.selectedPeriod,
      customStart: currentState.customStart,
      customEnd: currentState.customEnd,
    );
  }

  Future<ChartsState> _load(ChartPeriodType period, {DateTime? customStart, DateTime? customEnd}) async {
    final user = await _usersDao.getActiveUser();
    final (from, to) = _computeDateRange(period, customStart: customStart, customEnd: customEnd);

    _logger.info(runtimeType, '_load: period=$period from=$from to=$to');

    final transactions = await _transactionsDao.getAllTransactions(user?.id, from, to);

    final double income = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);
    // expense amounts are stored as negative values; balance = income + expense is correct
    final double expense = TransactionUtils.getTotalTransactionAmounts(transactions);
    final double balance = TransactionUtils.roundDouble(income + expense);

    final topCategories = _buildTopCategories(transactions);
    final monthlyPoints = _buildMonthlyPoints(transactions);
    final topPaymentMethods = await _buildPaymentMethods(user?.id, transactions);

    return ChartsState.loaded(
      loaded: true,
      selectedPeriod: period,
      customStart: customStart,
      customEnd: customEnd,
      totalIncome: income,
      totalExpense: expense,
      balance: balance,
      topCategories: topCategories,
      monthlyPoints: monthlyPoints,
      topPaymentMethods: topPaymentMethods,
    );
  }

  (DateTime, DateTime) _computeDateRange(
    ChartPeriodType period, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return switch (period) {
      ChartPeriodType.last30days => (now.subtract(const Duration(days: 30)), today),
      ChartPeriodType.last3months => (now.subtract(const Duration(days: 90)), today),
      ChartPeriodType.last12months => (now.subtract(const Duration(days: 365)), today),
      ChartPeriodType.allTime => (DateTime(2000), today),
      ChartPeriodType.custom =>
        customStart != null && customEnd != null ? (customStart, customEnd) : (now.subtract(const Duration(days: 30)), today),
    };
  }

  List<CategoryChartItem> _buildTopCategories(List<TransactionItem> transactions) {
    final expenseTransactions = transactions.where((t) => !t.category.isAnIncome).toList();
    final grouped = <String, double>{};
    final categoryMeta = <String, (Color, IconData?, bool)>{};

    for (final t in expenseTransactions) {
      final key = t.category.name;
      grouped[key] = TransactionUtils.roundDouble((grouped[key] ?? 0) + t.amount.abs());
      categoryMeta.putIfAbsent(
        key,
        () => (t.category.iconColor ?? Colors.grey, t.category.icon, t.category.isAnIncome),
      );
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];

    return grouped.entries.sortedByCompare((e) => e.value, (a, b) => b.compareTo(a)).take(5).map((e) {
      final (color, icon, isAnIncome) = categoryMeta[e.key]!;
      return CategoryChartItem(
        categoryName: e.key,
        total: e.value,
        percentage: TransactionUtils.roundDouble((e.value / total) * 100),
        color: color,
        isAnIncome: isAnIncome,
        icon: icon ?? Icons.label,
      );
    }).toList();
  }

  Future<List<PaymentMethodChartItem>> _buildPaymentMethods(int? userId, List<TransactionItem> transactions) async {
    final expenseTransactions = transactions.where((t) => !t.category.isAnIncome).toList();
    final grouped = <int, double>{};

    for (final t in expenseTransactions) {
      final key = t.paymentMethodId ?? -1;
      grouped[key] = TransactionUtils.roundDouble((grouped[key] ?? 0) + t.amount.abs());
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return [];
    }

    final paymentMethods = await _paymentMethodsDao.getAllByIds(userId, grouped.keys.toList());

    return grouped.entries.sortedByCompare((e) => e.value, (a, b) => b.compareTo(a)).mapIndexed(
      (index, e) {
        final percentage = TransactionUtils.roundDouble((e.value / total) * 100);
        final paymentMethod = paymentMethods.firstWhereOrNull((p) => p.id == e.key);
        if (paymentMethod == null) {
          return PaymentMethodChartItem(methodName: '', total: e.value, percentage: percentage);
        }

        return PaymentMethodChartItem(
          methodName: paymentMethod.name,
          icon: paymentMethod.icon,
          iconColor: paymentMethod.iconColor,
          total: e.value,
          percentage: percentage,
        );
      },
    ).toList();
  }

  List<TransactionActivityPerDate> _buildMonthlyPoints(List<TransactionItem> transactions) {
    final months = <DateTime, (double, double)>{};
    for (final t in transactions) {
      final key = DateTime(t.transactionDate.year, t.transactionDate.month);
      final (inc, exp) = months[key] ?? (0.0, 0.0);
      if (t.category.isAnIncome) {
        months[key] = (TransactionUtils.roundDouble(inc + t.amount), exp);
      } else {
        months[key] = (inc, TransactionUtils.roundDouble(exp + t.amount));
      }
    }

    return months.entries.sortedBy((e) => e.key).map((e) {
      final (inc, exp) = e.value;
      return TransactionActivityPerDate(
        income: inc,
        expense: exp,
        balance: TransactionUtils.roundDouble(inc + exp),
      );
    }).toList();
  }
}

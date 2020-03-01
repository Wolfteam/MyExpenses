import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../common/utils/date_utils.dart';
import '../../common/utils/i18n_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../models/transaction_card_items.dart';
import '../../models/transaction_item.dart';
import '../../models/transactions_summary_per_day.dart';
import '../../models/transactions_summary_per_month.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final SettingsService _settingsService;

  TransactionsBloc(
    this._logger,
    this._transactionsDao,
    this._settingsService,
  );

  @override
  TransactionsState get initialState => TransactionsInitialState();

  @override
  Stream<TransactionsState> mapEventToState(
    TransactionsEvent event,
  ) async* {
    if (event is GetTransactions) {
      yield* _buildInitialState(event);
    }
  }

  Stream<TransactionsLoadedState> _buildInitialState(
    GetTransactions event,
  ) async* {
    final month = DateUtils.formatAppDate(
      event.inThisDate,
      _settingsService.language,
      DateUtils.fullMonthFormat,
    );
    final from = DateUtils.getFirstDayDateOfTheMonth(event.inThisDate);
    final to = DateUtils.getLastDayDateOfTheMonth(from);

    _logger.info(
      runtimeType,
      '_buildInitialState: Getting all the transactions from = $from to = $to',
    );

    try {
      final transactions = await _transactionsDao.getAllTransactions(from, to);

      final incomes = _getTotalIncomes(transactions);
      final expenses = _getTotalExpenses(transactions);
      final balance = incomes + expenses;
      final monthBalance = _buildMonthBalance(incomes, expenses, transactions);

      final incomeTransPerWeek =
          await _buildTransactionSummaryPerDay(onlyIncomes: true);
      final expenseTransPerWeek =
          await _buildTransactionSummaryPerDay(onlyIncomes: false);

      final transPerMonth = _buildTransactionsPerMonth(transactions);

      yield TransactionsLoadedState(
        month: month,
        incomeAmount: incomes,
        expenseAmount: expenses,
        balanceAmount: balance,
        currentDate: event.inThisDate,
        showLast7Days: DateTime.now().month == event.inThisDate.month,
        monthBalance: monthBalance,
        incomeTransactionsPerWeek: incomeTransPerWeek,
        expenseTransactionsPerWeek: expenseTransPerWeek,
        transactionsPerMonth: transPerMonth,
      );
    } on Exception catch (e, s) {
      _logger.error(
          runtimeType, '_buildInitialState: An unknown error occurred', e, s);
      yield TransactionsLoadedState(
        month: month,
        incomeAmount: 0,
        expenseAmount: 0,
        balanceAmount: 0,
        currentDate: event.inThisDate,
        showLast7Days: DateTime.now().month == event.inThisDate.month,
        monthBalance: _buildMonthBalance(0, 0, []),
        incomeTransactionsPerWeek: [],
        expenseTransactionsPerWeek: [],
        transactionsPerMonth: _buildTransactionsPerMonth([]),
      );
    }
  }

  double _getTotalExpenses(List<TransactionItem> transactions) =>
      getTotalTransactionAmounts(transactions, onlyIncomes: false);

  double _getTotalIncomes(List<TransactionItem> transactions) =>
      getTotalTransactionAmounts(transactions, onlyIncomes: true);

  List<TransactionsSummaryPerMonth> _buildMonthBalance(
    double incomes,
    double expenses,
    List<TransactionItem> transactions,
  ) {
    final balance = (expenses.abs() + incomes).abs();
    if (transactions.isNotEmpty) {
      final expensesPercentage = (expenses * 100 / balance).abs().round();
      final incomesPercentage = (incomes * 100 / balance).round();

      return [
        TransactionsSummaryPerMonth(
          order: 0,
          percentage: expensesPercentage,
          isAnIncome: false,
        ),
        TransactionsSummaryPerMonth(
          order: 1,
          percentage: incomesPercentage,
          isAnIncome: true,
        ),
      ];
    }

    return [
      TransactionsSummaryPerMonth(
        order: 1,
        percentage: 100,
        isAnIncome: true,
      ),
    ];
  }

  Future<List<TransactionsSummaryPerDay>> _buildTransactionSummaryPerDay({
    bool onlyIncomes,
  }) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final from = DateTime(
      sevenDaysAgo.year,
      sevenDaysAgo.month,
      sevenDaysAgo.day,
    );

    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _logger.info(
      runtimeType,
      '_buildTransactionSummaryPerDay: Getting ${onlyIncomes ? "income" : "expense"} transactions summary from = $from to = $to',
    );

    try {
      final transactions = (await _transactionsDao.getAllTransactions(from, to))
          .where((t) => t.category.isAnIncome == onlyIncomes)
          .toList();

      final map = <DateTime, double>{};
      for (final transaction in transactions) {
        final date = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );

        if (map.keys.any((key) => key == date)) {
          map[date] += transaction.amount;
        } else {
          map.addAll({date: transaction.amount});
        }
      }

      for (var i = 0; i <= 6; i++) {
        final mustExistDate = from.add(Duration(days: i));
        if (map.containsKey(mustExistDate)) continue;

        map.addAll({mustExistDate: 0.0});
      }

      final models = map.entries
          .map((kvp) => TransactionsSummaryPerDay(
                date: kvp.key,
                amount: kvp.value.round(),
              ))
          .toList();

      models.sort((t1, t2) => t1.createdAt.compareTo(t2.createdAt));
      return models;
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_buildTransactionSummaryPerDay: Unknown error ocurred',
        e,
        s,
      );
      return [];
    }
  }

  List<TransactionCardItems> _buildTransactionsPerMonth(
    List<TransactionItem> transactions,
  ) {
    final transPerMonth = <DateTime, List<TransactionItem>>{};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      if (transPerMonth.keys.any((key) => key == date)) {
        transPerMonth[date].add(transaction);
      } else {
        transPerMonth.addAll({
          date: [transaction]
        });
      }
    }

    final models = <TransactionCardItems>[];

    for (final kvp in transPerMonth.entries) {
      final dateString = DateUtils.formatAppDate(
        kvp.key,
        _settingsService.language,
        DateUtils.dayAndMonthFormat,
      );

      final dayString = DateUtils.formatAppDate(
        kvp.key,
        _settingsService.language,
        DateUtils.dayStringFormat,
      );

      final locale = currentLocaleString(_settingsService.language);

      final dateSummary =
          '$dateString ${toBeginningOfSentenceCase(dayString, locale)}';

      models.add(TransactionCardItems(
        date: kvp.key,
        dateString: dateSummary,
        transactions: kvp.value,
      ));
    }

    models.sort((t1, t2) => t2.date.compareTo(t1.date));

    return models;
  }
}

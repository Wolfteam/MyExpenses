import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../common/utils/transaction_utils.dart';
import '../../models/entities/database.dart';
import '../../models/transaction_card_items.dart';
import '../../models/transaction_item.dart';
import '../../models/transactions_summary_per_day.dart';
import '../../models/transactions_summary_per_month.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final AppDatabase db;

  TransactionsBloc({
    @required this.db,
  });

  @override
  TransactionsState get initialState => TransactionsInitialState();

  @override
  Stream<TransactionsState> mapEventToState(
    TransactionsEvent event,
  ) async* {
    yield TransactionsInitialState();

    if (event is GetTransactions) {
      final month = DateFormat("MMMM").format(event.inThisDate);
      final from = DateTime(event.inThisDate.year, event.inThisDate.month, 1);
      final to = (from.month < 12)
          ? DateTime(from.year, from.month + 1, 0)
          : DateTime(from.year + 1, 1, 0);
      final transactions = await db.transactionsDao.getAll(from, to);

      final incomes = _getTotalIncomes(transactions);
      final expenses = _getTotalExpenses(transactions);
      final balance = incomes + expenses;
      final monthBalance =
          _buildMonthBalance(incomes, expenses, balance, transactions);

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
        monthBalance: monthBalance,
        incomeTransactionsPerWeek: incomeTransPerWeek,
        expenseTransactionsPerWeek: expenseTransPerWeek,
        transactionsPerMonth: transPerMonth,
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
    double balance,
    List<TransactionItem> transactions,
  ) {
    final expensesPercentage = (expenses * 100 / balance.abs()).round();
    final incomesPercentage = (incomes * 100 / balance.abs()).round();

    return [
      TransactionsSummaryPerMonth(0, expensesPercentage),
      TransactionsSummaryPerMonth(1, incomesPercentage),
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

    final transactions = (await db.transactionsDao.getAll(from, to))
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
      final dateString = DateFormat('MM/dd EEEE').format(kvp.key);
      models.add(TransactionCardItems(
        date: kvp.key,
        dateString: dateString,
        transactions: kvp.value,
      ));
    }

    models.sort((t1, t2) => t2.date.compareTo(t1.date));

    return models;
  }
}

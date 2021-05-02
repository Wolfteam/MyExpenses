import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/utils/date_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/transaction_card_items.dart';
import '../../models/transaction_item.dart';
import '../../models/transactions_summary_per_day.dart';
import '../../models/transactions_summary_per_month.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';
import '../transactions_last_7_days/transactions_last_7_days_bloc.dart';
import '../transactions_per_month/transactions_per_month_bloc.dart';

part 'transactions_bloc.freezed.dart';
part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  final TransactionsPerMonthBloc _transactionsPerMonthBloc;
  final TransactionsLast7DaysBloc _transactionsLast7DaysBloc;

  TransactionsBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
    this._transactionsPerMonthBloc,
    this._transactionsLast7DaysBloc,
  ) : super(const TransactionsState.loading());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<TransactionsState> mapEventToState(TransactionsEvent event) async* {
    final s = await event.map(
      loadTransactions: (e) => _loadTransactions(e.inThisDate),
      loadRecurringTransactions: (_) => _loadRecurringTransactions(),
    );

    yield s;
  }

  Future<TransactionsState> _loadTransactions(DateTime inThisDate) async {
    final month = toBeginningOfSentenceCase(DateUtils.formatAppDate(inThisDate, _settingsService.language, DateUtils.fullMonthFormat));
    final now = DateTime.now();
    final from = DateUtils.getFirstDayDateOfTheMonth(inThisDate);
    final to = DateUtils.getLastDayDateOfTheMonth(from);

    try {
      if (from.isBefore(now) || from.isAtSameMomentAs(now)) {
        await TransactionUtils.checkRecurringTransactions(now, _logger, _transactionsDao, _usersDao);
      }

      _logger.info(runtimeType, '_buildInitialState: Getting all the transactions from = $from to = $to');
      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllTransactions(currentUser?.id, from, to);

      final incomes = _getTotalIncomes(transactions);
      final expenses = _getTotalExpenses(transactions);
      final balance = TransactionUtils.roundDouble(incomes + expenses);

      _logger.info(runtimeType, '_buildInitialState: Generating month balance...');
      final monthBalance = _buildMonthBalance(incomes, expenses, transactions);

      _logger.info(runtimeType, '_buildInitialState: Generating incomes / expenses transactions per week...');

      final incomeTransPerWeek = await _buildTransactionSummaryPerDay(true);
      final expenseTransPerWeek = await _buildTransactionSummaryPerDay(false);

      _logger.info(runtimeType, '_buildInitialState: Generating transactions per month..');

      final transPerMonth = TransactionUtils.buildTransactionsPerMonth(_settingsService.language, transactions);

      _transactionsPerMonthBloc.add(
        TransactionsPerMonthEvent.init(
          incomes: incomes,
          expenses: expenses,
          total: balance,
          month: month!,
          transactions: monthBalance,
          currentDate: inThisDate,
        ),
      );

      final showLast7Days = DateTime.now().month == inThisDate.month;
      if (state is! _InitialState) {
        _transactionsLast7DaysBloc.add(TransactionsLast7DaysEvent.init(
          selectedType: TransactionType.incomes,
          incomes: incomeTransPerWeek,
          expenses: expenseTransPerWeek,
          showLast7Days: showLast7Days,
        ));

        return TransactionsState.initial(currentDate: inThisDate, transactionsPerMonth: transPerMonth, language: _settingsService.language);
      }

      _transactionsLast7DaysBloc.add(TransactionsLast7DaysEvent.init(
        incomes: incomeTransPerWeek,
        expenses: expenseTransPerWeek,
        showLast7Days: showLast7Days,
      ));

      return currentState.copyWith.call(
        currentDate: inThisDate,
        transactionsPerMonth: transPerMonth,
        language: _settingsService.language,
        showParentTransactions: false,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_buildInitialState: An unknown error occurred', e, s);
      return TransactionsState.initial(currentDate: inThisDate, transactionsPerMonth: [], language: _settingsService.language);
    }
  }

  Future<TransactionsState> _loadRecurringTransactions() async {
    try {
      _logger.info(runtimeType, '_buildRecurringState: Getting all parent transactions...');
      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllParentTransactions(currentUser?.id);
      final transPerMonth = TransactionUtils.buildTransactionsPerMonth(_settingsService.language, transactions, sortByNextRecurringDate: true);

      return currentState.copyWith(showParentTransactions: true, transactionsPerMonth: transPerMonth);
    } catch (e, s) {
      _logger.error(runtimeType, '_buildRecurringState: Unknown error', e, s);
      return currentState.copyWith(showParentTransactions: true, transactionsPerMonth: []);
    }
  }

  double _getTotalExpenses(List<TransactionItem> transactions) => TransactionUtils.getTotalTransactionAmounts(transactions);

  double _getTotalIncomes(List<TransactionItem> transactions) => TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);

  List<TransactionsSummaryPerMonth> _buildMonthBalance(
    double incomes,
    double expenses,
    List<TransactionItem> transactions,
  ) {
    if (transactions.isNotEmpty) {
      final incomeAmount = incomes <= 0 ? 0 : incomes;
      final double expensesPercentage = incomeAmount <= 0 ? 100 : (expenses * 100 / incomeAmount).abs();
      final double incomesPercentage = expensesPercentage >= 100 ? 0 : 100 - expensesPercentage;

      return [
        TransactionsSummaryPerMonth(
          order: 0,
          percentage: TransactionUtils.roundDouble(expensesPercentage),
          isAnIncome: false,
        ),
        TransactionsSummaryPerMonth(
          order: 1,
          percentage: TransactionUtils.roundDouble(incomesPercentage),
          isAnIncome: true,
        ),
      ];
    }

    return [
      const TransactionsSummaryPerMonth(
        order: 1,
        percentage: 100,
        isAnIncome: true,
      ),
    ];
  }

  Future<List<TransactionsSummaryPerDay>> _buildTransactionSummaryPerDay(bool onlyIncomes) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final from = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);

    final to = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _logger.info(
      runtimeType,
      '_buildTransactionSummaryPerDay: Getting ${onlyIncomes ? "income" : "expense"} transactions summary from = $from to = $to',
    );

    try {
      final currentUser = await _usersDao.getActiveUser();
      final transactions =
          (await _transactionsDao.getAllTransactions(currentUser?.id, from, to)).where((t) => t.category.isAnIncome == onlyIncomes).toList();

      final map = <DateTime, double>{};
      for (final transaction in transactions) {
        final date = DateTime(
          transaction.transactionDate.year,
          transaction.transactionDate.month,
          transaction.transactionDate.day,
        );

        if (map.keys.any((key) => key == date)) {
          map[date] = transaction.amount + map[date]!;
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
                totalDayAmount: kvp.value,
              ))
          .toList();

      models.sort((t1, t2) => t1.date.compareTo(t2.date));
      return models;
    } catch (e, s) {
      _logger.error(runtimeType, '_buildTransactionSummaryPerDay: Unknown error ocurred', e, s);
      return [];
    }
  }
}

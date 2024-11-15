import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'transactions_bloc.freezed.dart';
part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;
  final TransactionsPerMonthBloc _transactionsPerMonthBloc;

  TransactionsBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
    this._transactionsPerMonthBloc,
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
    final month = toBeginningOfSentenceCase(
      DateUtils.formatAppDate(inThisDate, _settingsService.getCurrentLanguageModel(), DateUtils.fullMonthFormat),
    );
    final from = DateUtils.getFirstDayDateOfTheMonth(inThisDate);
    final to = DateUtils.getLastDayDateOfTheMonth(from);

    try {
      final currentUser = await _usersDao.getActiveUser();
      _logger.info(runtimeType, '_buildInitialState: Getting all the transactions from = $from to = $to');

      final transactions = await _transactionsDao.getAllTransactions(currentUser?.id, from, to);

      final incomes = _getTotalIncomes(transactions);
      final expenses = _getTotalExpenses(transactions);
      final balance = TransactionUtils.roundDouble(incomes + expenses);

      _logger.info(runtimeType, '_buildInitialState: Generating month balance...');
      final monthBalance = _buildMonthBalance(incomes, expenses, transactions);

      _logger.info(runtimeType, '_buildInitialState: Generating transactions per month..');
      final transPerMonth = TransactionUtils.buildTransactionsPerMonth(_settingsService.getCurrentLanguageModel(), transactions);

      _transactionsPerMonthBloc.add(
        TransactionsPerMonthEvent.init(
          incomes: incomes,
          expenses: expenses,
          total: balance,
          month: month,
          transactions: monthBalance,
          currentDate: inThisDate,
        ),
      );

      if (state is! _InitialState) {
        return TransactionsState.initial(
          currentDate: inThisDate,
          transactionsPerMonth: transPerMonth,
          language: _settingsService.getCurrentLanguageModel(),
        );
      }

      return currentState.copyWith.call(
        currentDate: inThisDate,
        transactionsPerMonth: transPerMonth,
        language: _settingsService.getCurrentLanguageModel(),
        showParentTransactions: false,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_buildInitialState: An unknown error occurred', e, s);
      return TransactionsState.initial(
        currentDate: inThisDate,
        transactionsPerMonth: [],
        language: _settingsService.getCurrentLanguageModel(),
      );
    }
  }

  Future<TransactionsState> _loadRecurringTransactions() async {
    try {
      _logger.info(runtimeType, '_buildRecurringState: Getting all parent transactions...');
      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllParentTransactions(currentUser?.id);
      final transPerMonth = TransactionUtils.buildTransactionsPerMonth(
        _settingsService.getCurrentLanguageModel(),
        transactions,
        sortByNextRecurringDate: true,
      );

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
      final total = incomes.abs() + expenses.abs();
      final double expensesPercentage = expenses.abs() * 100 / total;
      final double incomesPercentage = incomes * 100 / total;

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

    return const [
      TransactionsSummaryPerMonth(
        order: 0,
        percentage: 0,
        isAnIncome: false,
      ),
      TransactionsSummaryPerMonth(
        order: 1,
        percentage: 0,
        isAnIncome: true,
      ),
    ];
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
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

  TransactionsBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
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

      _logger.info(runtimeType, '_buildInitialState: Generating transactions per month..');
      final transPerMonth = TransactionUtils.buildTransactionsPerMonth(_settingsService.getCurrentLanguageModel(), transactions);

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
}

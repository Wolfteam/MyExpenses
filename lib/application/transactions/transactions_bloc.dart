import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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

  @override
  Stream<TransactionsState> mapEventToState(TransactionsEvent event) async* {
    final s = await event.map(init: (e) => _handle(e.currentDate));
    yield s;
  }

  Future<TransactionsState> _handle(DateTime date) async {
    if (state.maybeMap(loaded: (state) => state.currentDate == date, orElse: () => false)) {
      return state;
    }
    final LanguageModel language = _settingsService.getCurrentLanguageModel();
    final DateTime from = DateUtils.getFirstDayDateOfTheMonth(date);
    final DateTime to = DateUtils.getLastDayDateOfTheMonth(from);

    try {
      final UserItem? currentUser = await _usersDao.getActiveUser();
      _logger.info(runtimeType, '_handle: Getting all the transactions from = $from to = $to');

      final List<TransactionItem> transactions = await _transactionsDao.getAllTransactions(currentUser?.id, from, to);
      final List<TransactionItem> recurringTransactions = await _transactionsDao.getAllParentTransactions(currentUser?.id);
      return TransactionsState.loaded(
        currentDate: date,
        language: language,
        transactions: TransactionUtils.buildTransactionsPerMonth(language, transactions),
        recurringTransactions: TransactionUtils.buildTransactionsPerMonth(language, recurringTransactions, sortByNextRecurringDate: true),
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_handle: An unknown error occurred', e, s);
      return TransactionsState.loaded(currentDate: date, language: language, transactions: [], recurringTransactions: []);
    }
  }
}

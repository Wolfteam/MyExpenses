import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/utils/date_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'estimates_bloc.freezed.dart';
part 'estimates_event.dart';
part 'estimates_state.dart';

class EstimatesBloc extends Bloc<EstimatesEvent, EstimatesState> {
  final LoggingService _logger;
  final SettingsService _settings;
  final UsersDao _usersDao;
  final TransactionsDao _transactionsDao;
  EstimatesBloc(this._logger, this._settings, this._usersDao, this._transactionsDao) : super(EstimatesState.loading());

  EstimatesInitialState get currentState => state as EstimatesInitialState;

  @override
  Stream<EstimatesState> mapEventToState(
    EstimatesEvent event,
  ) async* {
    final s = event.map(
      load: (_) async => _calculateAmounts(0, DateTime.now()),
      transactionTypeChanged: (e) async => currentState.copyWith.call(selectedTransactionType: e.newValue),
      untilDateChanged: (e) async {
        final dateString = DateUtils.formatAppDate(e.newDate, _settings.language, DateUtils.monthDayAndYearFormat);
        return currentState.copyWith.call(untilDate: e.newDate, untilDateString: dateString);
      },
      calculate: (e) => _calculateAmounts(currentState.selectedTransactionType, currentState.untilDate),
    );

    yield await s;
  }

  Future<EstimatesState> _calculateAmounts(int transactionType, DateTime until) async {
    final now = DateTime.now();
    final firstDate = DateUtils.getFirstDayDateOfTheMonth(now);
    final firstDateString = DateUtils.formatAppDate(firstDate, _settings.language, DateUtils.monthDayAndYearFormat);
    final lastDate = DateUtils.getLastDayDateOfTheMonth(until);
    final lastDateString = DateUtils.formatAppDate(lastDate, _settings.language, DateUtils.monthDayAndYearFormat);
    try {
      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllTransactions(currentUser?.id, firstDate, now);
      final parentTransactions = await _transactionsDao.getAllParentTransactions(currentUser?.id);
      final filteredParents = _generateNextTransactions(parentTransactions, lastDate);
      transactions.addAll(filteredParents);

      final incomes = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);
      final expenses = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: false);
      final balance = TransactionUtils.roundDouble(incomes + expenses);
      return EstimatesState.loaded(
        selectedTransactionType: transactionType,
        fromDate: firstDate,
        fromDateString: firstDateString,
        untilDate: lastDate,
        untilDateString: lastDateString,
        currentLanguage: _settings.language,
        expenseAmount: expenses,
        incomeAmount: incomes,
        totalAmount: balance,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_calculateAmounts: Unknown error', e, s);
      return EstimatesState.loaded(
        selectedTransactionType: transactionType,
        fromDate: firstDate,
        fromDateString: firstDateString,
        untilDate: until,
        untilDateString: lastDateString,
        currentLanguage: _settings.language,
      );
    }
  }

  List<TransactionItem> _generateNextTransactions(List<TransactionItem> parentTransactions, DateTime untilDate) {
    final now = DateTime.now();
    final transactions = <TransactionItem>[];
    for (final parent in parentTransactions) {
      if (parent.nextRecurringDate == null) {
        continue;
      }
      final tuple = TransactionUtils.getRecurringTransactionPeriods(
        parent.repetitionCycle,
        parent.nextRecurringDate,
        untilDate,
      );

      final periods = tuple.item2.where((period) => period.isAfter(now)).toList();
      for (var i = 0; i < periods.length; i++) {
        transactions.add(parent);
      }
    }

    return transactions;
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'estimates_bloc.freezed.dart';
part 'estimates_event.dart';
part 'estimates_state.dart';

class EstimatesBloc extends Bloc<EstimatesEvent, EstimatesState> {
  final LoggingService _logger;
  final SettingsService _settings;
  final UsersDao _usersDao;
  final TransactionsDao _transactionsDao;

  EstimatesBloc(this._logger, this._settings, this._usersDao, this._transactionsDao) : super(const EstimatesState.loading()) {
    on<EstimatesEventEstimatesLoadEvent>((event, emit) async {
      final s = await _calculateAmounts(
        0,
        DateUtils.getFirstDayDateOfTheMonth(DateTime.now()),
        DateUtils.getLastDayDateOfTheMonth(DateTime.now()),
      );
      emit(s);
    });

    on<EstimatesEventEstimatesTransactionTypeChangedEvent>((event, emit) {
      final s = currentState.copyWith.call(selectedTransactionType: event.newValue);
      emit(s);
    });

    on<EstimatesEventEstimatesFromDateChangedEvent>((event, emit) {
      final from = event.newDate;
      var until = currentState.untilDate;
      if (from.isAfter(until)) {
        until = from;
      }
      final s = _datesChanged(from, until);
      emit(s);
    });

    on<EstimatesEventEstimatesUntilDateChangedEvent>((event, emit) {
      var from = currentState.fromDate;
      if (event.newDate.isBefore(from)) {
        from = event.newDate.add(const Duration(days: -1));
      }
      final s = _datesChanged(from, event.newDate);
      emit(s);
    });

    on<EstimatesEventEstimatesCalculateEvent>((event, emit) async {
      final s = await _calculateAmounts(currentState.selectedTransactionType, currentState.fromDate, currentState.untilDate);
      emit(s);
    });
  }

  EstimatesStateEstimatesInitialState get currentState => state as EstimatesStateEstimatesInitialState;

  Future<EstimatesState> _calculateAmounts(int transactionType, DateTime from, DateTime until) async {
    final lang = _settings.getCurrentLanguageModel();
    final fromDateString = DateUtils.formatAppDate(from, lang, DateUtils.monthDayAndYearFormat);
    final untilDateString = DateUtils.formatAppDate(until, lang, DateUtils.monthDayAndYearFormat);
    try {
      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllTransactions(currentUser?.id, from, until);
      final parentTransactions = await _transactionsDao.getAllParentTransactions(currentUser?.id);
      final filteredParents = _generateNextTransactions(parentTransactions, until);
      transactions.addAll(filteredParents);

      final incomes = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);
      final expenses = TransactionUtils.getTotalTransactionAmounts(transactions);
      final balance = TransactionUtils.roundDouble(incomes + expenses);
      return EstimatesState.loaded(
        selectedTransactionType: transactionType,
        fromDate: from,
        fromDateString: fromDateString,
        untilDate: until,
        untilDateString: untilDateString,
        currentLanguage: _settings.language,
        expenseAmount: expenses,
        incomeAmount: incomes,
        totalAmount: balance,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_calculateAmounts: Unknown error', e, s);
      return EstimatesState.loaded(
        selectedTransactionType: transactionType,
        fromDate: from,
        fromDateString: fromDateString,
        untilDate: until,
        untilDateString: untilDateString,
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
        parent.transactionDate,
        parent.nextRecurringDate!,
        untilDate,
      );

      final periods = tuple.$2.where((period) => period.isAfter(now)).toList();
      for (var i = 0; i < periods.length; i++) {
        transactions.add(parent);
      }
    }

    return transactions;
  }

  EstimatesState _datesChanged(DateTime from, DateTime until) {
    final lang = _settings.getCurrentLanguageModel();
    final fromDateString = DateUtils.formatAppDate(from, lang, DateUtils.monthDayAndYearFormat);
    final untilDateString = DateUtils.formatAppDate(until, lang, DateUtils.monthDayAndYearFormat);
    return currentState.copyWith.call(
      fromDate: from,
      fromDateString: fromDateString,
      untilDate: until,
      untilDateString: untilDateString,
    );
  }
}

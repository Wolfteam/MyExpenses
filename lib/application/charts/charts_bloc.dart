import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'charts_bloc.freezed.dart';
part 'charts_event.dart';
part 'charts_state.dart';

final _now = DateTime.now();
final _defaultState = ChartsState.loaded(
  currentYear: _now.month,
  currentMonthDate: _now,
  currentMonthDateString: '',
  transactionsPerMonth: [],
  transactionsPerYear: [],
  transactions: [],
  language: AppLanguageType.english,
);

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  ChartsBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
  ) : super(_defaultState);

  @override
  Stream<ChartsState> mapEventToState(
    ChartsEvent event,
  ) async* {
    yield _defaultState;
    final s = await event.map(loadChart: (e) async => _buildLoadedState(e.selectedMonthDate, e.selectedYear));
    yield s;
  }

  Future<ChartsState> _buildLoadedState(DateTime selectedMonthDate, int selectedYear) async {
    final dateString = toBeginningOfSentenceCase(
      DateUtils.formatAppDate(selectedMonthDate, _settingsService.getCurrentLanguageModel(), DateUtils.fullMonthAndYearFormat),
    );
    final from = DateUtils.getFirstDayDateOfTheMonth(selectedMonthDate);
    final to = DateUtils.getLastDayDateOfTheMonth(selectedMonthDate);
    var transactions = <TransactionItem>[];
    var transactionsPerMonth = <TransactionsSummaryPerDate>[];
    var transactionsPerYear = <TransactionsSummaryPerYear>[];

    try {
      _logger.info(runtimeType, '_buildLoadedState: Trying to get all the transactions from = $from to = $to');
      final currentUser = await _usersDao.getActiveUser();
      transactions = await _transactionsDao.getAllTransactions(currentUser?.id, from, to);
      transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

      _logger.info(runtimeType, '_buildLoadedState: Mapping the transaction to the corresponding state');
      transactionsPerMonth = _buildTransactionSummaryPerDate(from, to, transactions);
      transactionsPerYear = await _buildTransactionSummaryPerYear(selectedYear, userId: currentUser?.id);
    } catch (e, s) {
      _logger.error(runtimeType, '_buildLoadedState: An unknown error occurred', e, s);
    }

    return ChartsState.loaded(
      currentYear: selectedYear,
      currentMonthDate: selectedMonthDate,
      currentMonthDateString: dateString!,
      transactionsPerMonth: transactionsPerMonth,
      transactionsPerYear: transactionsPerYear,
      transactions: transactions,
      language: _settingsService.language,
    );
  }

  List<TransactionsSummaryPerDate> _buildTransactionSummaryPerDate(DateTime from, DateTime to, List<TransactionItem> transactions) {
    final trans = <TransactionsSummaryPerDate>[];
    final lang = _settingsService.getCurrentLanguageModel();
    final days = to.difference(from).inDays;

    for (var i = 0; i < days; i++) {
      final now = from.add(Duration(days: i));
      final first = DateTime(now.year, now.month, now.day);

      final next = _getNextDate(first);
      final last = DateTime(next.year, next.month, next.day, 23, 59, 59);

      final amount = TransactionUtils.getTotalTransactionAmount(
        transactions.where((t) => t.transactionDate.isAfter(first) && t.transactionDate.isBefore(last)).toList(),
      );

      final start = DateUtils.formatAppDate(first, lang);
      final end = DateUtils.formatAppDate(last, lang);

      final dateRangeString = '$start - $end';

      trans.add(TransactionsSummaryPerDate(totalAmount: amount, dateRangeString: dateRangeString));

      i += last.difference(first).inDays;
    }

    return trans;
  }

  Future<List<TransactionsSummaryPerYear>> _buildTransactionSummaryPerYear(int year, {int? userId}) async {
    final maxMonth = year != _now.year
        ? DateTime.december
        : _now.month == DateTime.december
            ? DateTime.december
            : _now.month;
    final from = DateUtils.getFirstDayDateOfTheMonth(DateTime(year));
    final until = DateUtils.getLastDayDateOfTheMonth(DateTime(year, maxMonth));
    final transactions = await _transactionsDao.getAllTransactions(userId, from, until);
    final grouped = <TransactionsSummaryPerYear>[];
    for (var i = DateTime.january; i <= maxMonth; i++) {
      final monthlyAmount = transactions.where((el) => el.transactionDate.month == i).map((el) => el.amount).sum;
      grouped.add(TransactionsSummaryPerYear(month: i, totalAmount: monthlyAmount));
    }

    return grouped;
  }

  DateTime _getNextDate(DateTime from) {
    const daysToAdd = Duration(days: 1);
    DateTime date = from;
    do {
      date = date.add(daysToAdd);
    } while (date.weekday != DateTime.sunday);

    if (date.month == from.month) return date;
    return DateUtils.getLastDayDateOfTheMonth(from);
  }
}

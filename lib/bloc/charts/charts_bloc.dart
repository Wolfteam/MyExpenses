import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../common/utils/date_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../models/chart_transaction_item.dart';
import '../../models/transaction_item.dart';
import '../../models/transactions_summary_per_date.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'charts_event.dart';
part 'charts_state.dart';

class ChartsBloc extends Bloc<ChartsEvent, ChartsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final SettingsService _settingsService;

  @override
  ChartsState get initialState => LoadingState();

  ChartsBloc(this._logger, this._transactionsDao, this._settingsService);

  @override
  Stream<ChartsState> mapEventToState(
    ChartsEvent event,
  ) async* {
    if (event is LoadChart) {
      yield* _buildLoadedState(event.from);
    }
  }

  Stream<ChartsState> _buildLoadedState(DateTime now) async* {
    final dateString = DateUtils.formatAppDate(
      now,
      _settingsService.language,
      DateUtils.fullMonthAndYearFormat,
    );
    final from = DateUtils.getFirstDayDateOfTheMonth(now);
    final to = DateUtils.getLastDayDateOfTheMonth(now);
    var transactions = <TransactionItem>[];
    var trans = <TransactionsSummaryPerDate>[];

    try {
      _logger.info(
        runtimeType,
        '_buildLoadedState: Trying to get all the transactions from = $from to = $to',
      );
      transactions = await _transactionsDao.getAllTransactions(from, to);
      transactions
          .sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

      _logger.info(
        runtimeType,
        '_buildLoadedState: Mapping the transaction to the corresponding state',
      );
      trans = _buildTransactionSummaryPerDate(from, to, transactions);
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_buildLoadedState: An unknown error occurred',
        e,
        s,
      );
    }

    yield LoadedState(
      now,
      dateString,
      trans,
      transactions,
    );
  }

  List<TransactionsSummaryPerDate> _buildTransactionSummaryPerDate(
    DateTime from,
    DateTime to,
    List<TransactionItem> transactions,
  ) {
    final trans = <TransactionsSummaryPerDate>[];
    final lang = _settingsService.language;
    final days = to.difference(from).inDays;

    for (var i = 0; i < days; i++) {
      final now = from.add(Duration(days: i));
      final first = DateTime(now.year, now.month, now.day, 0, 0, 0);

      final next = _getNextDate(first);
      final last = DateTime(next.year, next.month, next.day, 23, 59, 59);

      final amount = TransactionUtils.getTotalTransactionAmount(transactions
          .where((t) =>
              t.transactionDate.isAfter(first) &&
              t.transactionDate.isBefore(last))
          .toList());

      final start = DateUtils.formatAppDate(
        first,
        lang,
        DateUtils.dayAndMonthFormat,
      );
      final end = DateUtils.formatAppDate(
        last,
        lang,
        DateUtils.dayAndMonthFormat,
      );

      final dateRangeString = '$start - $end';

      trans.add(TransactionsSummaryPerDate(amount, dateRangeString));

      i += last.difference(first).inDays;
    }

    return trans;
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

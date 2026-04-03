import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'trend_chart_bloc.freezed.dart';
part 'trend_chart_event.dart';
part 'trend_chart_state.dart';

class TrendChartBloc extends Bloc<TrendChartEvent, TrendChartState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;

  TrendChartBloc(this._logger, this._transactionsDao, this._usersDao)
    : super(const TrendChartState.loaded(loaded: false, trendPoints: [], monthlyPoints: [])) {
    on<TrendChartEventLoad>((event, emit) async {
      final user = await _usersDao.getActiveUser();
      _logger.info(runtimeType, 'load: from=${event.from} to=${event.to}');
      final transactions = await _transactionsDao.getAllTransactions(user?.id, event.from, event.to);
      emit(
        TrendChartState.loaded(
          loaded: true,
          trendPoints: _buildWeeklyPoints(transactions),
          monthlyPoints: _buildMonthlyPoints(transactions),
        ),
      );
    });
  }

  List<TransactionActivityPerDate> _buildWeeklyPoints(List<TransactionItem> transactions) {
    final weeks = <DateTime, (double, double)>{};
    for (final t in transactions) {
      final weekStart = t.transactionDate.subtract(Duration(days: t.transactionDate.weekday - 1));
      final key = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final (inc, exp) = weeks[key] ?? (0.0, 0.0);
      if (t.category.isAnIncome) {
        weeks[key] = (TransactionUtils.roundDouble(inc + t.amount), exp);
      } else {
        weeks[key] = (inc, TransactionUtils.roundDouble(exp + t.amount));
      }
    }

    double runningBalance = 0;
    return weeks.entries.sortedBy((e) => e.key).map((e) {
      final (inc, exp) = e.value;
      runningBalance = TransactionUtils.roundDouble(runningBalance + inc + exp);
      final label = DateUtils.formatDateWithoutLocale(e.key);
      return TransactionActivityPerDate(
        income: inc,
        expense: exp,
        balance: runningBalance,
        dateRangeString: label,
      );
    }).toList();
  }

  List<TransactionActivityPerDate> _buildMonthlyPoints(List<TransactionItem> transactions) {
    final months = <DateTime, (double, double)>{};
    for (final t in transactions) {
      final key = DateTime(t.transactionDate.year, t.transactionDate.month);
      final (inc, exp) = months[key] ?? (0.0, 0.0);
      if (t.category.isAnIncome) {
        months[key] = (TransactionUtils.roundDouble(inc + t.amount), exp);
      } else {
        months[key] = (inc, TransactionUtils.roundDouble(exp + t.amount));
      }
    }

    final sorted = months.entries.sortedBy((e) => e.key);
    final spansMultipleYears = sorted.length > 1 &&
        sorted.first.key.year != sorted.last.key.year;
    final format = spansMultipleYears ? 'MMM yy' : 'MMM';

    return sorted.map((e) {
      final (inc, exp) = e.value;
      final label = DateUtils.formatDateWithoutLocale(e.key, format);
      return TransactionActivityPerDate(
        income: inc,
        expense: exp,
        balance: TransactionUtils.roundDouble(inc + exp),
        dateRangeString: label,
      );
    }).toList();
  }
}

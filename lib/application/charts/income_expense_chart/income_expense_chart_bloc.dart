import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'income_expense_chart_bloc.freezed.dart';
part 'income_expense_chart_event.dart';
part 'income_expense_chart_state.dart';

class IncomeExpenseChartBloc extends Bloc<IncomeExpenseChartEvent, IncomeExpenseChartState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;

  IncomeExpenseChartBloc(this._logger, this._transactionsDao, this._usersDao)
      : super(const IncomeExpenseChartState.loaded(loaded: false, points: [])) {
    on<IncomeExpenseChartEventLoad>((event, emit) async {
      final user = await _usersDao.getActiveUser();
      _logger.info(runtimeType, 'load: from=${event.from} to=${event.to}');
      final transactions = await _transactionsDao.getAllTransactions(user?.id, event.from, event.to);
      emit(IncomeExpenseChartState.loaded(loaded: true, points: _buildMonthlyPoints(transactions)));
    });
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
    final dateFormat = spansMultipleYears
        ? DateFormat('MMM yy')
        : DateFormat.MMM();

    return sorted.map((e) {
      final (inc, exp) = e.value;
      return TransactionActivityPerDate(
        income: inc,
        expense: exp,
        balance: TransactionUtils.roundDouble(inc + exp),
        dateRangeString: dateFormat.format(e.key),
      );
    }).toList();
  }
}

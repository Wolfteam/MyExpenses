import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'transactions_summary_per_month_bloc.freezed.dart';
part 'transactions_summary_per_month_event.dart';
part 'transactions_summary_per_month_state.dart';

class TransactionsSummaryPerMonthBloc extends Bloc<TransactionsSummaryPerMonthEvent, TransactionsSummaryPerMonthState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  TransactionsSummaryPerMonthBloc(this._logger, this._transactionsDao, this._usersDao, this._settingsService)
    : super(const TransactionsSummaryPerMonthState.loading()) {
    on<TransactionsSummaryPerMonthEventInit>((event, emit) async {
      final s = await _handle(event.currentDate);
      emit(s);
    });
  }

  Future<TransactionsSummaryPerMonthState> _handle(DateTime date) async {
    try {
      _logger.info(runtimeType, '_handle: Generating month summary for month ${date.month}...');
      final UserItem? currentUser = await _usersDao.getActiveUser();

      final DateTime from = DateUtils.getFirstDayDateOfTheMonth(date);
      final DateTime to = DateUtils.getLastDayDateOfTheMonth(from);

      final double income = await _transactionsDao.getAmount(currentUser?.id, from, to, true);
      final double expense = await _transactionsDao.getAmount(currentUser?.id, from, to, false);
      final double total = TransactionUtils.roundDouble(income.abs() + expense.abs());
      final double balance = TransactionUtils.roundDouble(income + expense);
      final double incomePercentage = total == 0 ? 0 : TransactionUtils.roundDouble(income * 100 / total);
      final double expensePercentage = total == 0 ? 0 : TransactionUtils.roundDouble(expense.abs() * 100 / total);

      final String month = toBeginningOfSentenceCase(
        DateUtils.formatAppDate(date, _settingsService.getCurrentLanguageModel(), DateUtils.fullMonthFormat),
      );

      return TransactionsSummaryPerMonthState.loaded(
        month: month,
        income: income,
        expense: expense,
        balance: balance,
        incomePercentage: incomePercentage,
        expensePercentage: expensePercentage,
        currentDate: date,
        language: _settingsService.language,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_handle: An unknown error occurred', e, s);
      return state;
    }
  }
}

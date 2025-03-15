import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/datetime_extensions.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'transactions_activity_bloc.freezed.dart';
part 'transactions_activity_event.dart';
part 'transactions_activity_state.dart';

final _initialState = TransactionsActivityState.loaded(
  loaded: false,
  currentDate: DateTime.now(),
  balance: 0,
  type: TransactionActivityDateRangeType.last7days,
  transactions: [],
  selectedActivityTypes: TransactionActivityType.values,
);

class TransactionsActivityBloc extends Bloc<TransactionsActivityEvent, TransactionsActivityState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  TransactionsActivityBloc(this._logger, this._transactionsDao, this._usersDao, this._settingsService) : super(_initialState) {
    on<TransactionsActivityEventInit>((event, emit) async {
      final UserItem? currentUser = await _usersDao.getActiveUser();
      final s = await _handleChange(DateTime.now(), TransactionActivityDateRangeType.last7days, userId: currentUser?.id);
      emit(s);
    });

    on<TransactionsActivityEventDateChanged>((event, emit) async {
      final UserItem? currentUser = await _usersDao.getActiveUser();
      final s = await _handleChange(event.currentDate, state.type, userId: currentUser?.id);
      emit(s);
    });

    on<TransactionsActivityEventDateRangeChanged>((event, emit) async {
      final UserItem? currentUser = await _usersDao.getActiveUser();
      final s = await _handleChange(state.currentDate, event.type, userId: currentUser?.id);
      emit(s);
    });

    on<TransactionsActivityEventActivitySelected>((event, emit) async {
      final s = await _handleActivityTypeChange(event.type);
      emit(s);
    });
  }

  Future<TransactionsActivityState> _handleActivityTypeChange(TransactionActivityType type) {
    final List<TransactionActivityType> activityTypes = [...state.selectedActivityTypes];
    if (activityTypes.contains(type)) {
      activityTypes.remove(type);
    } else {
      activityTypes.add(type);
    }

    return Future.value(state.copyWith(selectedActivityTypes: activityTypes));
  }

  Future<TransactionsActivityState> _handleChange(
    DateTime currentDate,
    TransactionActivityDateRangeType type, {
    int? userId,
  }) async {
    List<TransactionActivityPerDate> transactions = [];
    switch (type) {
      case TransactionActivityDateRangeType.last7days:
        transactions = await _buildLast7Days(userId: userId);
      case TransactionActivityDateRangeType.monthly:
        final from = DateUtils.getFirstDayDateOfTheMonth(currentDate);
        final to = DateUtils.getLastDayDateOfTheMonth(currentDate);
        transactions = await _buildPerDateRange(from, to, userId: userId);
      case TransactionActivityDateRangeType.yearly:
        transactions = await _buildPerYear(currentDate.year, userId: userId);
    }

    final double balance = TransactionUtils.getTotalAmounts(transactions.map((e) => e.balance));
    return state.copyWith(loaded: true, transactions: transactions, balance: balance, type: type, currentDate: currentDate);
  }

  Future<List<TransactionActivityPerDate>> _buildLast7Days({int? userId}) async {
    final now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 6));
    final from = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
    final until = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _logger.info(runtimeType, '_buildLast7Days: Getting income + expenses transactions summary from = $from until = $until');

    final List<TransactionItem> transactions = await _transactionsDao.getAllTransactions(userId, from, until);
    return _buildPerDay(from, transactions);
  }

  List<TransactionActivityPerDate> _buildPerDay(DateTime from, List<TransactionItem> transactions) {
    final groupedPerDay = <DateTime, TransactionActivityPerDate>{};
    final lang = _settingsService.getCurrentLanguageModel();
    for (final TransactionItem transaction in transactions) {
      final date = DateTime(transaction.transactionDate.year, transaction.transactionDate.month, transaction.transactionDate.day);

      if (groupedPerDay.containsKey(date)) {
        final TransactionActivityPerDate existing = groupedPerDay[date]!;
        if (transaction.category.isAnIncome) {
          groupedPerDay[date] = existing.copyWith(income: existing.income + transaction.amount);
        } else {
          groupedPerDay[date] = existing.copyWith(expense: existing.expense + transaction.amount);
        }
      } else {
        final String dateRangeString = DateUtils.formatAppDate(date, lang);
        groupedPerDay[date] = TransactionActivityPerDate(
          income: transaction.category.isAnIncome ? transaction.amount : 0,
          expense: !transaction.category.isAnIncome ? transaction.amount : 0,
          balance: 0,
          dateRangeString: dateRangeString,
        );
      }
    }

    for (int i = 0; i <= DateTime.daysPerWeek - 1; i++) {
      final DateTime mustExistDate = from.add(Duration(days: i));
      if (groupedPerDay.containsKey(mustExistDate)) {
        continue;
      }
      final String dateRangeString = DateUtils.formatAppDate(mustExistDate, lang);
      final activity = TransactionActivityPerDate(income: 0, balance: 0, expense: 0, dateRangeString: dateRangeString);
      groupedPerDay.addAll({mustExistDate: activity});
    }

    return groupedPerDay.entries.sortedBy((kvp) => kvp.key).map((kvp) {
      final TransactionActivityPerDate trans = kvp.value;
      final double income = TransactionUtils.roundDouble(trans.income);
      final double expenses = TransactionUtils.roundDouble(trans.expense);
      final double balance = TransactionUtils.roundDouble(income + expenses);
      return trans.copyWith(income: income, expense: expenses, balance: balance);
    }).toList();
  }

  Future<List<TransactionActivityPerDate>> _buildPerDateRange(DateTime from, DateTime until, {int? userId}) async {
    _logger.info(runtimeType, '_buildPerDateRange: Getting income + expenses transactions summary from = $from to = $until');

    final List<TransactionItem> transactions = await _transactionsDao.getAllTransactions(userId, from, until);
    transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

    final grouped = <TransactionActivityPerDate>[];
    final lang = _settingsService.getCurrentLanguageModel();
    final int days = until.difference(from).inDays;

    for (int i = 0; i < days; i++) {
      final DateTime now = from.add(Duration(days: i));
      final DateTime first = DateTime(now.year, now.month, now.day);
      final DateTime next = _getNextDate(first);
      final DateTime last = DateTime(next.year, next.month, next.day, 23, 59, 59);

      final transInDateRange = transactions.where((t) => t.transactionDate.isBetweenInclusive(first, last)).toList();
      final double income = TransactionUtils.getTotalTransactionAmounts(transInDateRange, onlyIncomes: true);
      final double expenses = TransactionUtils.getTotalTransactionAmounts(transInDateRange);
      final double balance = TransactionUtils.roundDouble(income + expenses);

      final String start = DateUtils.formatAppDate(first, lang, DateUtils.dayStringFormat);
      final String end = DateUtils.formatAppDate(last, lang, DateUtils.dayStringFormat);
      final String dateRangeString = '$start - $end';

      final activity = TransactionActivityPerDate(
        income: income,
        expense: expenses,
        balance: balance,
        dateRangeString: dateRangeString,
      );
      grouped.add(activity);

      i += last.difference(first).inDays;
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

  Future<List<TransactionActivityPerDate>> _buildPerYear(int year, {int? userId}) async {
    final now = DateTime.now();
    final maxMonth =
        year != now.year
            ? DateTime.december
            : now.month == DateTime.december
            ? DateTime.december
            : now.month;
    final from = DateUtils.getFirstDayDateOfTheMonth(DateTime(year));
    final until = DateUtils.getLastDayDateOfTheMonth(DateTime(year, maxMonth));
    _logger.info(runtimeType, '_buildPerYear: Getting income + expenses transactions summary from = $from to = $until');

    final transactions = await _transactionsDao.getAllTransactions(userId, from, until);
    final grouped = <TransactionActivityPerDate>[];
    for (int i = DateTime.january; i <= maxMonth; i++) {
      final double income = TransactionUtils.getTotalAmounts(
        transactions.where((el) => el.transactionDate.month == i && el.category.isAnIncome).map((el) => el.amount),
      );
      final double expense = TransactionUtils.getTotalAmounts(
        transactions.where((el) => el.transactionDate.month == i && !el.category.isAnIncome).map((el) => el.amount),
      );
      final double monthly = TransactionUtils.roundDouble(income + expense);

      final activity = TransactionActivityPerDate(income: income, expense: expense, balance: monthly);
      grouped.add(activity);
    }

    return grouped;
  }
}

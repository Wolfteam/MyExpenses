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

part 'transactions_bloc.freezed.dart';
part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  TransactionsBloc(this._logger, this._transactionsDao, this._usersDao, this._settingsService) : super(const TransactionsState.loading());

  @override
  Stream<TransactionsState> mapEventToState(TransactionsEvent event) async* {
    final s = await event.map(
      init: (e) => _handle(e.currentDate, TransactionFilterType.date, SortDirectionType.desc),
      groupingTypeChanged:
          (e) => state.map(
            loading: (_) => throw Exception('Invalid state'),
            loaded: (state) => _handle(state.currentDate, e.type, state.sortDirectionType),
          ),
      sortDirectionTypeChanged:
          (e) =>
              state.map(loading: (_) => throw Exception('Invalid state'), loaded: (state) => _handle(state.currentDate, state.groupingType, e.type)),
    );
    yield s;
  }

  Future<TransactionsState> _handle(DateTime date, TransactionFilterType groupingType, SortDirectionType sortDirectionType) async {
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
        groupingType: groupingType,
        sortDirectionType: sortDirectionType,
        transactions: TransactionUtils.buildTransactionsPerMonth(language, transactions, sortType: sortDirectionType),
        recurringTransactions: TransactionUtils.buildTransactionsPerMonth(language, recurringTransactions, sortByNextRecurringDate: true),
        groupedTransactionsByCategory:
            groupingType == TransactionFilterType.category ? _groupByCategory([...transactions], sortDirectionType) : <TransactionCardItems>[],
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_handle: An unknown error occurred', e, s);
      return TransactionsState.loaded(
        currentDate: date,
        language: language,
        groupingType: groupingType,
        sortDirectionType: sortDirectionType,
        transactions: [],
        recurringTransactions: [],
        groupedTransactionsByCategory: [],
      );
    }
  }

  void _sortTransactions(List<TransactionItem> transactions, TransactionFilterType groupingType, SortDirectionType sortDirectionType) {
    switch (groupingType) {
      case TransactionFilterType.description:
        if (sortDirectionType == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.description.compareTo(t2.description));
        } else {
          transactions.sort((t1, t2) => t2.description.compareTo(t1.description));
        }
      case TransactionFilterType.amount:
        if (sortDirectionType == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.amount.abs().compareTo(t2.amount.abs()));
        } else {
          transactions.sort((t1, t2) => t2.amount.abs().compareTo(t1.amount.abs()));
        }
      case TransactionFilterType.date:
        if (sortDirectionType == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));
        } else {
          transactions.sort((t1, t2) => t2.transactionDate.compareTo(t1.transactionDate));
        }
      case TransactionFilterType.category:
        break;
    }
  }

  List<TransactionCardItems> _groupByCategory(List<TransactionItem> transactions, SortDirectionType sortDirectionType) {
    final List<CategoryItem> categories = transactions.map((t) => t.category).toList();
    final List<int> catsIds = categories.map((c) => c.id).toSet().toList();
    final grouped = <TransactionCardItems>[];
    for (final int catId in catsIds) {
      final CategoryItem category = categories.firstWhere((c) => c.id == catId);
      final List<TransactionItem> trans = transactions.where((t) => t.category.id == catId).toList();
      _sortTransactions(trans, TransactionFilterType.amount, sortDirectionType);

      final group = TransactionCardItems(
        groupedBy: category.name,
        transactions: trans,
        income: TransactionUtils.getTotalTransactionAmounts(trans, onlyIncomes: true),
        expense: TransactionUtils.getTotalTransactionAmounts(trans),
        balance: TransactionUtils.getTotalTransactionAmount(trans),
      );
      grouped.add(group);
    }

    if (sortDirectionType == SortDirectionType.asc) {
      grouped.sort((t1, t2) => t1.balance.abs().compareTo(t2.balance.abs()));
    } else {
      grouped.sort((t1, t2) => t2.balance.abs().compareTo(t1.balance.abs()));
    }

    return grouped;
  }
}

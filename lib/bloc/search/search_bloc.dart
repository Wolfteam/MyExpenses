import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/enums/comparer_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/transaction_filter_type.dart';
import '../../common/enums/transaction_type.dart';
import '../../common/utils/date_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../models/category_item.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'search_bloc.freezed.dart';
part 'search_state.dart';

class SearchBloc extends Cubit<SearchState> {
  final LoggingService _loggingService;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  SearchInitialState get currentState => state as SearchInitialState;

  SearchBloc(
    this._loggingService,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
  ) : super(SearchState.loading());

  Future<void> init() async {
    final now = DateTime.now();
    final from = DateUtils.getFirstDayDateOfTheMonth(now);
    final to = DateUtils.getLastDayDateOfTheMonth(now);

    return _buildInitialState(_settingsService.language, from: from, to: to);
  }

  Future<void> descriptionChanged(String newValue) {
    final s = currentState;

    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.until,
      description: newValue,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<void> applyTempDates() {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.tempFrom,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  void tempFromDateChanged(DateTime newValue) {
    final correctedDates = DateUtils.correctDates(newValue, currentState.tempUntil);
    _tempDatesChanged(correctedDates.item1, correctedDates.item2);
  }

  void tempToDateChanged(DateTime newValue) {
    final correctedDates = DateUtils.correctDates(currentState.tempFrom, newValue, fromHasPriority: false);
    _tempDatesChanged(correctedDates.item1, correctedDates.item2);
  }

  void resetTempDates() => _tempDatesChanged(currentState.from, currentState.until);

  Future<void> applyTempAmount() {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.tempAmount,
      comparerType: s.tempComparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  void tempAmountChanged(double newValue) => emit(currentState.copyWith.call(tempAmount: newValue));

  void tempComparerTypeChanged(ComparerType newValue) => emit(currentState.copyWith.call(tempComparerType: newValue));

  Future<void> comparerTypeChanged(ComparerType newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: newValue,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<void> categoryChanged(CategoryItem newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: newValue,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<void> transactionFilterChanged(TransactionFilterType newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: newValue,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<void> sortDirectionchanged(SortDirectionType newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: newValue,
    );
  }

  Future<void> transactionTypeChanged(int newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: newValue < 0 ? null : TransactionType.values.firstWhere((el) => el.index == newValue),
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<void> _buildInitialState(
    AppLanguageType languageType, {
    DateTime from,
    DateTime to,
    String description,
    double amount,
    ComparerType comparerType = ComparerType.equal,
    CategoryItem category,
    TransactionType transactionType,
    TransactionFilterType transactionFilterType = TransactionFilterType.date,
    SortDirectionType sortDirectionType = SortDirectionType.desc,
  }) async {
    final currentUser = await _usersDao.getActiveUser();
    final transactions = await _transactionsDao.getAllTransactionsForSearch(
      currentUser?.id,
      from,
      to,
      description,
      amount,
      comparerType,
      category?.id,
      transactionType,
      transactionFilterType,
      sortDirectionType,
    );

    if (state is! SearchInitialState) {
      final s = SearchState.initial(
        currentLanguage: languageType,
        from: from,
        until: to,
        description: description,
        amount: amount,
        tempAmount: amount,
        comparerType: comparerType,
        tempComparerType: comparerType,
        category: category,
        transactionType: transactionType,
        transactionFilterType: transactionFilterType,
        sortDirectionType: sortDirectionType,
        transactions: transactions,
        tempFrom: from,
        tempUntil: to,
        fromString: DateUtils.formatAppDate(from, languageType, DateUtils.monthDayAndYearFormat),
        untilString: DateUtils.formatAppDate(to, languageType, DateUtils.monthDayAndYearFormat),
      );
      emit(s);
      return;
    }

    final s = currentState.copyWith.call(
      from: from,
      until: to,
      description: description,
      amount: amount,
      tempAmount: amount,
      comparerType: comparerType,
      tempComparerType: comparerType,
      category: category,
      transactionType: transactionType,
      transactionFilterType: transactionFilterType,
      sortDirectionType: sortDirectionType,
      transactions: transactions,
      tempFrom: from,
      tempUntil: to,
      fromString: DateUtils.formatAppDate(from, languageType, DateUtils.monthDayAndYearFormat),
      untilString: DateUtils.formatAppDate(to, languageType, DateUtils.monthDayAndYearFormat),
    );
    emit(s);
  }

  void _tempDatesChanged(DateTime from, DateTime to) {
    final s = currentState.copyWith.call(
      tempFrom: from,
      fromString: DateUtils.formatAppDate(from, currentState.currentLanguage, DateUtils.monthDayAndYearFormat),
      tempUntil: to,
      untilString: DateUtils.formatAppDate(to, currentState.currentLanguage, DateUtils.monthDayAndYearFormat),
    );
    emit(s);
  }
}

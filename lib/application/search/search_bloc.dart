import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';

part 'search_bloc.freezed.dart';
part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  SearchStateInitialState get currentState => state as SearchStateInitialState;

  SearchBloc(this._logger, this._transactionsDao, this._usersDao, this._settingsService) : super(const SearchState.loading()) {
    on<SearchEventInit>((event, emit) async {
      emit(const SearchState.loading());
      final s = await _init();
      emit(s);
    });

    on<SearchEventLoadMore>((event, emit) async {
      final s = await _loadMore();
      emit(s);
    });

    on<SearchEventDescriptionChanged>((event, emit) async {
      final s = await _descriptionChanged(event.newValue);
      emit(s);
    });

    on<SearchEventApplyTempDates>((event, emit) async {
      final s = await _applyTempDates();
      emit(s);
    });

    on<SearchEventTempFromDateChanged>((event, emit) {
      final s = _tempFromDateChanged(event.newValue);
      emit(s);
    });

    on<SearchEventTempToDateChanged>((event, emit) {
      final s = _tempToDateChanged(event.newValue);
      emit(s);
    });

    on<SearchEventResetTempDates>((event, emit) {
      final s = _resetTempDates();
      emit(s);
    });

    on<SearchEventApplyTempAmount>((event, emit) async {
      final s = await _applyTempAmount();
      emit(s);
    });

    on<SearchEventTempAmountChanged>((event, emit) {
      final s = _tempAmountChanged(event.newValue);
      emit(s);
    });

    on<SearchEventTempComparerTypeChanged>((event, emit) {
      final s = _tempComparerTypeChanged(event.newValue);
      emit(s);
    });

    on<SearchEventComparerTypeChanged>((event, emit) async {
      final s = await _comparerTypeChanged(event.newValue);
      emit(s);
    });

    on<SearchEventCategoryChanged>((event, emit) async {
      final s = await _categoryChanged(event.newValue);
      emit(s);
    });

    on<SearchEventTransactionFilterChanged>((event, emit) async {
      final s = await _transactionFilterChanged(event.newValue);
      emit(s);
    });

    on<SearchEventSortDirectionChanged>((event, emit) async {
      final s = await _sortDirectionChanged(event.newValue);
      emit(s);
    });

    on<SearchEventTransactionTypeChanged>((event, emit) async {
      final s = await _transactionTypeChanged(event.newValue);
      emit(s);
    });
  }

  Future<SearchState> _init() {
    final now = DateTime.now();
    final from = DateUtils.getFirstDayDateOfTheMonth(now);
    final to = DateUtils.getLastDayDateOfTheMonth(now);

    return _buildInitialState(_settingsService.language, from: from, to: to);
  }

  Future<SearchState> _loadMore() async {
    final s = currentState;
    await Future.delayed(const Duration(milliseconds: 250));
    return _buildInitialState(
      s.currentLanguage,
      page: s.page + 1,
      from: s.from,
      to: s.until,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: s.transactionType,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<SearchState> _descriptionChanged(String newValue) {
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

  Future<SearchState> _applyTempDates() {
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

  SearchState _tempFromDateChanged(DateTime? newValue) {
    final correctedDates = DateUtils.correctDates(newValue, currentState.tempUntil);
    return _tempDatesChanged(correctedDates.$1, correctedDates.$2);
  }

  SearchState _tempToDateChanged(DateTime? newValue) {
    final correctedDates = DateUtils.correctDates(currentState.tempFrom, newValue, fromHasPriority: false);
    return _tempDatesChanged(correctedDates.$1, correctedDates.$2);
  }

  SearchState _resetTempDates() => _tempDatesChanged(currentState.from, currentState.until);

  Future<SearchState> _applyTempAmount() {
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

  SearchState _tempAmountChanged(double? newValue) => currentState.copyWith.call(tempAmount: newValue);

  SearchState _tempComparerTypeChanged(ComparerType newValue) => currentState.copyWith.call(tempComparerType: newValue);

  Future<SearchState> _comparerTypeChanged(ComparerType newValue) {
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

  Future<SearchState> _categoryChanged(CategoryItem? newValue) {
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

  Future<SearchState> _transactionFilterChanged(TransactionFilterType newValue) {
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

  Future<SearchState> _sortDirectionChanged(SortDirectionType newValue) {
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

  Future<SearchState> _transactionTypeChanged(TransactionType? newValue) {
    final s = currentState;
    return _buildInitialState(
      s.currentLanguage,
      from: s.from,
      to: s.tempUntil,
      description: s.description,
      amount: s.amount,
      comparerType: s.comparerType,
      category: s.category,
      transactionType: newValue,
      transactionFilterType: s.transactionFilterType,
      sortDirectionType: s.sortDirectionType,
    );
  }

  Future<SearchState> _buildInitialState(
    AppLanguageType languageType, {
    int take = 10,
    int page = 1,
    DateTime? from,
    DateTime? to,
    String? description,
    double? amount,
    ComparerType comparerType = ComparerType.equal,
    CategoryItem? category,
    TransactionType? transactionType,
    TransactionFilterType transactionFilterType = TransactionFilterType.date,
    SortDirectionType sortDirectionType = SortDirectionType.desc,
  }) async {
    final skip = take * (page - 1);
    try {
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
        take,
        skip,
      );
      final hasReachedMax = transactions.isEmpty || transactions.length < take;
      final lang = _settingsService.getCurrentLanguageModel();
      if (state is! SearchStateInitialState) {
        return SearchState.initial(
          currentLanguage: languageType,
          hasReachedMax: hasReachedMax,
          page: page,
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
          fromString: DateUtils.formatAppDate(from, lang, DateUtils.monthDayAndYearFormat),
          untilString: DateUtils.formatAppDate(to, lang, DateUtils.monthDayAndYearFormat),
        );
      }

      //If we can't load more results, avoid generating a new state
      if (currentState.hasReachedMax && page > 1) {
        return currentState;
      }

      return currentState.copyWith.call(
        hasReachedMax: hasReachedMax,
        page: page,
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
        transactions: page == 1 ? transactions : currentState.transactions + transactions,
        tempFrom: from,
        tempUntil: to,
        fromString: DateUtils.formatAppDate(from, lang, DateUtils.monthDayAndYearFormat),
        untilString: DateUtils.formatAppDate(to, lang, DateUtils.monthDayAndYearFormat),
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_buildInitialState: Unknown error occurred', e, s);
    }

    return currentState;
  }

  SearchState _tempDatesChanged(DateTime? from, DateTime? to) {
    final lang = _settingsService.getLanguageModel(currentState.currentLanguage);
    final s = currentState.copyWith.call(
      tempFrom: from,
      fromString: DateUtils.formatAppDate(from, lang, DateUtils.monthDayAndYearFormat),
      tempUntil: to,
      untilString: DateUtils.formatAppDate(to, lang, DateUtils.monthDayAndYearFormat),
    );
    return s;
  }
}

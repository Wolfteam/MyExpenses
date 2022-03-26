part of 'charts_bloc.dart';

@freezed
class ChartsState with _$ChartsState {
  double get totalIncomeAmount =>
      transactions.where((t) => t.category.isAnIncome == true).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));

  double get totalExpenseAmount =>
      transactions.where((t) => t.category.isAnIncome == false).map((t) => t.amount).fold(0, (t1, t2) => TransactionUtils.roundDouble(t1 + t2));

  const ChartsState._();

  const factory ChartsState.loaded({
    required int currentYear,
    required DateTime currentMonthDate,
    required String currentMonthDateString,
    required List<TransactionsSummaryPerDate> transactionsPerMonth,
    required List<TransactionsSummaryPerYear> transactionsPerYear,
    required List<TransactionItem> transactions,
    required AppLanguageType language,
  }) = _Loaded;
}

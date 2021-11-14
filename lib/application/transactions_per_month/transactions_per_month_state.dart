part of 'transactions_per_month_bloc.dart';

@freezed
class TransactionsPerMonthState with _$TransactionsPerMonthState {
  const factory TransactionsPerMonthState.loading() = _LoadingState;
  const factory TransactionsPerMonthState.initial({
    required double incomes,
    required double expenses,
    required double total,
    required String month,
    required List<TransactionsSummaryPerMonth> transactions,
    required AppLanguageType currentLanguage,
    required DateTime currentDate,
  }) = _InitialState;
}

part of 'transactions_summary_per_month_bloc.dart';

@freezed
class TransactionsSummaryPerMonthState with _$TransactionsSummaryPerMonthState {
  const factory TransactionsSummaryPerMonthState.loading() = _LoadingState;

  const factory TransactionsSummaryPerMonthState.loaded({
    required String month,
    required double income,
    required double expense,
    required double balance,
    required double incomePercentage,
    required double expensePercentage,
    required DateTime currentDate,
    required AppLanguageType language,
  }) = _LoadedState;
}

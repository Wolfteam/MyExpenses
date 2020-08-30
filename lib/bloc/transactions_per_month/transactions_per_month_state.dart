part of 'transactions_per_month_bloc.dart';

@freezed
abstract class TransactionsPerMonthState implements _$TransactionsPerMonthState {
  factory TransactionsPerMonthState.initial() = TransactionsPerMonthInitialState;
  factory TransactionsPerMonthState.loaded({
    @required double incomes,
    @required double expenses,
    @required double total,
    @required String month,
    @required List<TransactionsSummaryPerMonth> transactions,
    AppLanguageType currentLanguage,
    DateTime currentDate,
  }) = TransactionsPerMonthLoadedState;
}

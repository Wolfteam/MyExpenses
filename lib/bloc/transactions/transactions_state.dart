part of 'transactions_bloc.dart';

@freezed
class TransactionsState with _$TransactionsState {
  const factory TransactionsState.loading() = _LoadingState;
  const factory TransactionsState.initial({
    required DateTime currentDate,
    required List<TransactionCardItems> transactionsPerMonth,
    required AppLanguageType language,
    @Default(false) bool showParentTransactions,
  }) = _InitialState;
}

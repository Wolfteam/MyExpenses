part of 'transactions_bloc.dart';

@freezed
class TransactionsState with _$TransactionsState {
  const factory TransactionsState.loading() = _LoadingState;
  const factory TransactionsState.loaded({
    required DateTime currentDate,
    required LanguageModel language,
    required List<TransactionCardItems> transactions,
    required List<TransactionCardItems> recurringTransactions,
  }) = _LoadedState;
}

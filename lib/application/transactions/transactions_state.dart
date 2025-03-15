part of 'transactions_bloc.dart';

@freezed
sealed class TransactionsState with _$TransactionsState {
  const factory TransactionsState.loading() = TransactionsStateLoadingState;

  const factory TransactionsState.loaded({
    required DateTime currentDate,
    required LanguageModel language,
    required TransactionFilterType groupingType,
    required SortDirectionType sortDirectionType,
    required List<TransactionCardItems> transactions,
    required List<TransactionCardItems> recurringTransactions,
    required List<TransactionCardItems> groupedTransactionsByCategory,
  }) = TransactionsStateLoadedState;
}

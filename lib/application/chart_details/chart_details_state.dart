part of 'chart_details_bloc.dart';

@freezed
class ChartDetailsState with _$ChartDetailsState {
  const ChartDetailsState._();

  const factory ChartDetailsState.initial({
    required TransactionFilterType filter,
    required SortDirectionType sortDirection,
    required List<TransactionItem> transactions,
    required List<ChartGroupedTransactionsByCategory> groupedTransactionsByCategory,
  }) = _InitialState;

  double get transactionsTotalAmount => TransactionUtils.getTotalTransactionAmount(transactions);
}

part of 'chart_details_bloc.dart';

class ChartDetailsState extends Equatable {
  final TransactionFilterType filter;
  final SortDirectionType sortDirection;
  final List<TransactionItem> transactions;
  final List<ChartGroupedTransactionsByCategory> groupedTransactionsByCategory;

  double get transactionsTotalAmount => TransactionUtils.getTotalTransactionAmount(transactions);

  @override
  List<Object> get props => [
        filter,
        sortDirection,
        transactions,
      ];

  const ChartDetailsState({
    @required this.filter,
    @required this.sortDirection,
    @required this.transactions,
    this.groupedTransactionsByCategory,
  });

  factory ChartDetailsState.initial() {
    return const ChartDetailsState(
      filter: TransactionFilterType.date,
      sortDirection: SortDirectionType.asc,
      transactions: [],
      groupedTransactionsByCategory: [],
    );
  }

  ChartDetailsState copyWith({
    TransactionFilterType filter,
    SortDirectionType sortDirection,
    List<TransactionItem> transactions,
    List<ChartGroupedTransactionsByCategory> groupedTransactionsByCategory,
  }) {
    return ChartDetailsState(
      filter: filter ?? this.filter,
      sortDirection: sortDirection ?? this.sortDirection,
      transactions: transactions ?? this.transactions,
      groupedTransactionsByCategory: groupedTransactionsByCategory ?? this.groupedTransactionsByCategory,
    );
  }
}

part of 'chart_details_bloc.dart';

class ChartDetailsState extends Equatable {
  final ChartDetailsFilterType filter;
  final SortDirectionType sortDirection;
  final List<TransactionItem> transactions;

  int get transactionsTotalAmount =>
      TransactionUtils.getTotalTransactionAmount(transactions).round();

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
  });

  factory ChartDetailsState.initial() {
    return const ChartDetailsState(
      filter: ChartDetailsFilterType.date,
      sortDirection: SortDirectionType.asc,
      transactions: [],
    );
  }

  ChartDetailsState copyWith({
    ChartDetailsFilterType filter,
    SortDirectionType sortDirection,
    List<TransactionItem> transactions,
  }) {
    return ChartDetailsState(
      filter: filter ?? this.filter,
      sortDirection: sortDirection ?? this.sortDirection,
      transactions: transactions ?? this.transactions,
    );
  }
}

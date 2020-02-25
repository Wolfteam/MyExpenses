part of 'chart_details_bloc.dart';

abstract class ChartDetailsEvent extends Equatable {
  const ChartDetailsEvent();
}

class Initialize extends ChartDetailsEvent {
  final List<TransactionItem> transactions;

  @override
  List<Object> get props => [transactions];

  const Initialize(this.transactions);
}

class FilterChanged extends ChartDetailsEvent {
  final ChartDetailsFilterType selectedFilter;
  @override
  List<Object> get props => [];

  const FilterChanged(this.selectedFilter);
}

class SortDirectionChanged extends ChartDetailsEvent {
  final SortDirectionType selectedDirection;

  @override
  List<Object> get props => [selectedDirection];

  const SortDirectionChanged(this.selectedDirection);
}

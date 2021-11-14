import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';

part 'chart_details_bloc.freezed.dart';
part 'chart_details_event.dart';
part 'chart_details_state.dart';

const _defaultState = ChartDetailsState.initial(
  filter: TransactionFilterType.date,
  sortDirection: SortDirectionType.asc,
  transactions: [],
  groupedTransactionsByCategory: [],
);

class ChartDetailsBloc extends Bloc<ChartDetailsEvent, ChartDetailsState> {
  ChartDetailsBloc() : super(_defaultState);

  @override
  Stream<ChartDetailsState> mapEventToState(
    ChartDetailsEvent event,
  ) async* {
    final s = event.map(
      initialize: (e) => state.copyWith.call(transactions: e.transactions),
      filterChanged: (e) => _sort(e.selectedFilter, state.sortDirection),
      sortDirectionChanged: (e) => _sort(state.filter, e.selectedDirection),
    );

    yield s;
  }

  ChartDetailsState _sort(TransactionFilterType filter, SortDirectionType sortDirection) {
    final transactions = List<TransactionItem>.from(state.transactions);
    if (filter != TransactionFilterType.category) {
      _sortTransactions(transactions, filter, sortDirection);

      return state.copyWith(
        filter: filter,
        sortDirection: sortDirection,
        transactions: transactions,
        groupedTransactionsByCategory: [],
      );
    } else {
      return _groupByCategory(transactions, filter, sortDirection);
    }
  }

  void _sortTransactions(
    List<TransactionItem> transactions,
    TransactionFilterType filter,
    SortDirectionType sortDirection,
  ) {
    switch (filter) {
      case TransactionFilterType.description:
        if (sortDirection == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.description.compareTo(t2.description));
        } else {
          transactions.sort((t1, t2) => t2.description.compareTo(t1.description));
        }
        break;
      case TransactionFilterType.amount:
        if (sortDirection == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.amount.abs().compareTo(t2.amount.abs()));
        } else {
          transactions.sort((t1, t2) => t2.amount.abs().compareTo(t1.amount.abs()));
        }
        break;
      case TransactionFilterType.date:
        if (sortDirection == SortDirectionType.asc) {
          transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));
        } else {
          transactions.sort((t1, t2) => t2.transactionDate.compareTo(t1.transactionDate));
        }
        break;
      case TransactionFilterType.category:
        break;
      default:
        throw Exception('Invalid chart details filter');
    }
  }

  ChartDetailsState _groupByCategory(
    List<TransactionItem> transactions,
    TransactionFilterType filter,
    SortDirectionType sortDirection,
  ) {
    final categories = transactions.map((t) => t.category).toList();
    final catsIds = categories.map((c) => c.id).toSet().toList();
    final grouped = <ChartGroupedTransactionsByCategory>[];
    for (final catId in catsIds) {
      final category = categories.firstWhere((c) => c.id == catId);
      final trans = transactions.where((t) => t.category.id == catId).toList();

      _sortTransactions(
        transactions,
        TransactionFilterType.amount,
        sortDirection,
      );
      grouped.add(ChartGroupedTransactionsByCategory(category: category, transactions: trans));
    }

    if (sortDirection == SortDirectionType.asc) {
      grouped.sort((t1, t2) => t1.total.abs().compareTo(t2.total.abs()));
    } else {
      grouped.sort((t1, t2) => t2.total.abs().compareTo(t1.total.abs()));
    }

    return state.copyWith(
      filter: filter,
      sortDirection: sortDirection,
      transactions: transactions,
      groupedTransactionsByCategory: grouped,
    );
  }
}

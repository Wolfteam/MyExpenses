import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:my_expenses/common/utils/transaction_utils.dart';

import '../../common/enums/chart_details_filter_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../models/transaction_item.dart';

part 'chart_details_event.dart';
part 'chart_details_state.dart';

class ChartDetailsBloc extends Bloc<ChartDetailsEvent, ChartDetailsState> {
  @override
  ChartDetailsState get initialState => ChartDetailsState.initial();

  @override
  Stream<ChartDetailsState> mapEventToState(
    ChartDetailsEvent event,
  ) async* {
    if (event is Initialize) {
      yield ChartDetailsState.initial()
          .copyWith(transactions: event.transactions);
    }

    if (event is FilterChanged) {
      yield* _sort(event.selectedFilter, state.sortDirection);
    }

    if (event is SortDirectionChanged) {
      yield* _sort(state.filter, event.selectedDirection);
    }
  }

  Stream<ChartDetailsState> _sort(
    ChartDetailsFilterType filter,
    SortDirectionType sortDirection,
  ) async* {
    final transactions = List<TransactionItem>.from(state.transactions);
    switch (filter) {
      case ChartDetailsFilterType.name:
        if (sortDirection == SortDirectionType.asc) {
          transactions
              .sort((t1, t2) => t1.description.compareTo(t2.description));
        } else {
          transactions
              .sort((t1, t2) => t2.description.compareTo(t1.description));
        }
        break;
      case ChartDetailsFilterType.amount:
        if (sortDirection == SortDirectionType.asc) {
          transactions
              .sort((t1, t2) => t1.amount.abs().compareTo(t2.amount.abs()));
        } else {
          transactions
              .sort((t1, t2) => t2.amount.abs().compareTo(t1.amount.abs()));
        }
        break;
      case ChartDetailsFilterType.date:
        if (sortDirection == SortDirectionType.asc) {
          transactions.sort(
              (t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));
        } else {
          transactions.sort(
              (t1, t2) => t2.transactionDate.compareTo(t1.transactionDate));
        }
        break;
      default:
        throw Exception('Invalid chart details filter');
    }

    yield state.copyWith(
      filter: filter,
      sortDirection: sortDirection,
      transactions: transactions,
    );
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../common/enums/transaction_type.dart';

part 'transactions_last_7_days_event.dart';
part 'transactions_last_7_days_state.dart';

class TransactionsLast7DaysBloc
    extends Bloc<TransactionsLast7DaysEvent, TransactionsLast7DaysState> {
  @override
  TransactionsLast7DaysInitialState get initialState =>
      const TransactionsLast7DaysInitialState();

  @override
  Stream<TransactionsLast7DaysState> mapEventToState(
    TransactionsLast7DaysEvent event,
  ) async* {
    if (event is Last7DaysTransactionTypeChanged) {
      yield Last7DaysTransactionTypeChangedState(
        selectedType: event.selectedType,
      );
    }
  }
}

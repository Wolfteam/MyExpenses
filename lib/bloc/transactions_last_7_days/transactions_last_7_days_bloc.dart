import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

import '../../common/enums/transaction_type.dart';
import '../../models/transactions_summary_per_day.dart';

part 'transactions_last_7_days_bloc.freezed.dart';
part 'transactions_last_7_days_state.dart';

class TransactionsLast7DaysBloc extends Cubit<TransactionsLast7DaysState> {
  TransactionsLast7DaysBloc() : super(TransactionsLast7DaysState.initial());

  TransactionsLast7DaysLoadedState get currentState => state as TransactionsLast7DaysLoadedState;

  void transactionsLoaded({
    TransactionType selectedType,
    List<TransactionsSummaryPerDay> incomes = const [],
    List<TransactionsSummaryPerDay> expenses = const [],
    bool showLast7Days = true,
  }) {
    if (state is! TransactionsLast7DaysLoadedState) {
      emit(TransactionsLast7DaysState.loaded(
        showLast7Days: showLast7Days,
        selectedType: selectedType ?? TransactionType.incomes,
        incomes: incomes,
        expenses: expenses,
      ));
      return;
    }

    emit(currentState.copyWith.call(
      selectedType: selectedType ?? currentState.selectedType,
      incomes: incomes,
      expenses: expenses,
      showLast7Days: showLast7Days,
    ));
  }

  void transactionTypeChanged(TransactionType selectedType) =>
      emit(currentState.copyWith.call(selectedType: selectedType));
}

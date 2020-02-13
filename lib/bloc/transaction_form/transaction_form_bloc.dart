import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../models/category_item.dart';
import '../../common/extensions/string_extensions.dart';

part 'transaction_form_event.dart';
part 'transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  TransactionFormInitial get currentState => state as TransactionFormInitial;

  @override
  TransactionFormState get initialState => TransactionFormInitial.initial();

  @override
  Stream<TransactionFormState> mapEventToState(
    TransactionFormEvent event,
  ) async* {
    if (event is AmountChanged) {
      yield currentState.copyWith(
        amount: event.amount,
        isAmountValid: _isAmountValid(event.amount),
      );
    }

    if (event is DescriptionChanged) {
      yield currentState.copyWith(
        description: event.description,
        isDescriptionValid: _isDescriptionValid(event.description),
      );
    }

    if (event is RepetitionsChanged) {
      currentState.copyWith(
        repetitions: event.repetitions,
        isRepetitionsValid: _areRepetitionsValid(event.repetitions),
      );
    }
  }

  bool _isAmountValid(double amount) => amount > 0;

  bool _isDescriptionValid(String description) => !description.isNullOrEmpty();

  bool _areRepetitionsValid(int repetitions) => repetitions >= 0;
}

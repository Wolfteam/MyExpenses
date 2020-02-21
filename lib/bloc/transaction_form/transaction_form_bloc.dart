import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/category_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../models/category_item.dart';
import '../../models/transaction_item.dart';

part 'transaction_form_event.dart';
part 'transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  final TransactionsDao _transactionsDao;

  TransactionFormBloc(this._transactionsDao);

  TransactionFormLoadedState get currentState =>
      state as TransactionFormLoadedState;

  @override
  TransactionFormState get initialState => TransactionInitialState();

  @override
  Stream<TransactionFormState> mapEventToState(
    TransactionFormEvent event,
  ) async* {
    if (event is AddTransaction) {
      yield TransactionFormLoadedState.initial();
    }

    if (event is EditTransaction) {
      yield TransactionFormLoadedState.initial().copyWith(
        id: event.item.id,
        amount: event.item.amount,
        isAmountValid: true,
        isAmountDirty: true,
        category: event.item.category,
        isCategoryValid: true,
        description: event.item.description,
        isDescriptionValid: true,
        isDescriptionDirty: true,
        repetitions: event.item.repetitions,
        isRepetitionsValid: true,
        isRepetitionsDirty: true,
        repetitionCycle: event.item.repetitionCycleType,
        areRepetitionCyclesVisible: event.item.repetitions > 0,
        transactionDate: event.item.transactionDate,
        isTransactionDateValid: true,
      );
    }

    if (event is AmountChanged) {
      yield currentState.copyWith(
        amount: event.amount,
        isAmountValid: _isAmountValid(event.amount),
        isAmountDirty: true,
      );
    }

    if (event is DescriptionChanged) {
      yield currentState.copyWith(
        description: event.description,
        isDescriptionValid: _isDescriptionValid(event.description),
        isDescriptionDirty: true,
      );
    }

    if (event is RepetitionsChanged) {
      yield currentState.copyWith(
        repetitions: event.repetitions,
        isRepetitionsValid: _areRepetitionsValid(event.repetitions),
        isRepetitionsDirty: true,
        areRepetitionCyclesVisible: event.repetitions > 0,
      );
    }

    if (event is TransactionDateChanged) {
      yield currentState.copyWith(
        transactionDate: event.transactionDate,
        isTransactionDateValid: true,
      );
    }

    if (event is RepetitionCycleChanged) {
      yield currentState.copyWith(
        repetitionCycle: event.repetitionCycle,
      );
    }

    if (event is CategoryWasUpdated) {
      yield currentState.copyWith(
        category: event.category,
        isCategoryValid: true,
      );
    }

    if (event is DeleteTransaction) {
      yield* _deleteTransaction(currentState.id);
    }

    if (event is FormSubmitted) {
      yield* _saveTransaction(currentState.buildTransactionItem());
    }

    if (event is FormClosed) {
      yield TransactionInitialState();
    }
  }

  bool _isAmountValid(double amount) => amount != 0;

  bool _isDescriptionValid(String description) =>
      !description.isNullOrEmpty(minLength: 1);

  bool _areRepetitionsValid(int repetitions) => repetitions >= 0;

  Stream<TransactionFormState> _saveTransaction(
    TransactionItem transaction,
  ) async* {
    try {
      final createdTrans =
          await _transactionsDao.saveTransaction(transaction);

      yield TransactionSavedState(createdTrans);
    } catch (e) {
      yield currentState.copyWith(
        error: 'Unknown error while trying to save into db',
      );
    }
  }

  Stream<TransactionFormState> _deleteTransaction(int id) async* {
    try {
      await _transactionsDao.deleteTransaction(id);
      yield TransactionDeletedState();
    } catch (e) {
      yield currentState.copyWith(
        error: 'Unknown error while trying to delete transaction',
      );
    }
  }
}

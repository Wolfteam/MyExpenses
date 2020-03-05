import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/category_utils.dart';
import '../../common/utils/date_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../models/category_item.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
import '../../services/settings_service.dart';

part 'transaction_form_event.dart';
part 'transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final SettingsService _settingsService;

  TransactionFormBloc(
    this._logger,
    this._transactionsDao,
    this._settingsService,
  );

  TransactionFormLoadedState get currentState =>
      state as TransactionFormLoadedState;

  @override
  TransactionFormState get initialState => TransactionInitialState();

  @override
  Stream<TransactionFormState> mapEventToState(
    TransactionFormEvent event,
  ) async* {
    if (event is AddTransaction) {
      yield TransactionFormLoadedState.initial(_settingsService.language);
    }

    if (event is EditTransaction) {
      yield TransactionFormLoadedState.initial(_settingsService.language)
          .copyWith(
        id: event.item.id,
        amount: event.item.amount,
        isAmountValid: true,
        isAmountDirty: true,
        category: event.item.category,
        isCategoryValid: true,
        description: event.item.description,
        isDescriptionValid: true,
        isDescriptionDirty: true,
        repetitionCycle: event.item.repetitionCycle,
        transactionDate: event.item.transactionDate,
        isTransactionDateValid: _isTransactionDateValid(
          event.item.transactionDate,
          event.item.repetitionCycle,
        ),
        isParentTransaction: event.item.isParentTransaction,
        parentTransactionId: event.item.parentTransactionId,
        firstDate: event.item.transactionDate,
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

    if (event is TransactionDateChanged) {
      yield currentState.copyWith(
        transactionDate: event.transactionDate,
        isTransactionDateValid: true,
      );
    }

    if (event is RepetitionCycleChanged) {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final transactionDate =
          event.repetitionCycle == RepetitionCycleType.none ? now : tomorrow;
      final firstDate = event.repetitionCycle == RepetitionCycleType.none
          ? DateTime(now.year - 1)
          : tomorrow;
      yield currentState.copyWith(
        transactionDate: transactionDate,
        firstDate: firstDate,
        repetitionCycle: event.repetitionCycle,
        isTransactionDateValid: _isTransactionDateValid(
          currentState.transactionDate,
          currentState.repetitionCycle,
        ),
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

  bool _isDescriptionValid(String description) => !description.isNullOrEmpty(
        minLength: 1,
        maxLength: 255,
      );

  bool _isTransactionDateValid(DateTime date, RepetitionCycleType cycle) {
    if (cycle == RepetitionCycleType.none) return true;
    return date.difference(DateTime.now()).inDays >= 1;
  }

  Stream<TransactionFormState> _saveTransaction(
    TransactionItem transaction,
  ) async* {
    try {
      _logger.info(
        runtimeType,
        '_saveTransaction: Trying to save transaction = ${transaction.toJson()}',
      );
      final createdTrans = await _transactionsDao.saveTransaction(transaction);

      yield TransactionSavedState(createdTrans);
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_saveTransaction: Unknown error occurred:',
        e,
        s,
      );
      yield currentState.copyWith(errorOccurred: true);
      yield currentState.copyWith(errorOccurred: false);
    }
  }

  Stream<TransactionFormState> _deleteTransaction(int id) async* {
    try {
      _logger.info(
        runtimeType,
        '_deleteTransaction: Trying to delete transactionId = $id',
      );
      await _transactionsDao.deleteTransaction(id);
      yield TransactionDeletedState();
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_deleteTransaction: Unknown error occurred:',
        e,
        s,
      );
      yield currentState.copyWith(errorOccurred: true);
      yield currentState.copyWith(errorOccurred: false);
    }
  }
}

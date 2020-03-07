import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

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
      bool imageExists = false;
      if (!event.item.imagePath.isNullEmptyOrWhitespace) {
        imageExists = await File(event.item.imagePath).exists();
      }

      final firstDate = _getFirstDateToUse(event.item.repetitionCycle);

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
        firstDate: firstDate,
        imagePath: event.item.imagePath,
        imageExists: imageExists,
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
      final transactionDate = _getInitialDateToUse(event.repetitionCycle);
      final firstDate = _getFirstDateToUse(event.repetitionCycle);

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

    if (event is ImageChanged) {
      yield currentState.copyWith(
        imagePath: event.path,
        imageExists: event.imageExists,
      );
    }

    if (event is DeleteTransaction) {
      yield* _deleteTransaction(currentState.id);
    }

    if (event is FormSubmitted) {
      yield* _saveTransaction();
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

  Stream<TransactionFormState> _saveTransaction() async* {
    try {
      yield currentState.copyWith(isSavingForm: true);

      String imagePath;
      if (!currentState.imagePath.isNullEmptyOrWhitespace) {
        _logger.info(
          runtimeType,
          '_saveTransaction: Saving the image...',
        );
        final fileExists = await File(currentState.imagePath).exists();
        if (fileExists) {
          imagePath = await _saveImage(currentState.imagePath);
        }
      }
      final transaction = currentState.buildTransactionItem(imagePath);
      _logger.info(
        runtimeType,
        '_saveTransaction: Trying to save transaction = ${transaction.toJson()}',
      );

      final createdTrans = await _transactionsDao.saveTransaction(transaction);

      if (currentState.isNewTransaction) {
        yield TransactionChangedState.created(createdTrans.transactionDate);
      } else {
        yield TransactionChangedState.updated(createdTrans.transactionDate);
      }
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_saveTransaction: Unknown error occurred:',
        e,
        s,
      );
      yield currentState.copyWith(errorOccurred: true, isSavingForm: false);
      yield currentState.copyWith(errorOccurred: false, isSavingForm: false);
    }
  }

  Stream<TransactionFormState> _deleteTransaction(int id) async* {
    try {
      _logger.info(
        runtimeType,
        '_deleteTransaction: Trying to delete transactionId = $id',
      );
      final transToDelete = await _transactionsDao.getTransaction(id);
      await _transactionsDao.deleteTransaction(id);
      yield TransactionChangedState.deleted(transToDelete.transactionDate);
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

  Future<String> _saveImage(String path) async {
    try {
      _logger.info(
        runtimeType,
        '_saveTransaction: Trying to save image',
      );
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final finalPath = '${dir.path}/${now}_img.png';

      await File(finalPath).writeAsBytes(await File(path).readAsBytes());

      _logger.info(
        runtimeType,
        '_saveTransaction: Image was successfully saved',
      );

      return finalPath;
    } on Exception catch (e, s) {
      _logger.error(
        runtimeType,
        '_saveImage: Unknown error occurred:',
        e,
        s,
      );
      return null;
    }
  }

  DateTime _getFirstDateToUse(RepetitionCycleType cycle) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final inFifteenDate = DateUtils.getNextBiweeklyDate(now);

    final firstDate = cycle == RepetitionCycleType.none
        ? DateTime(now.year - 1)
        : cycle == RepetitionCycleType.biweekly ? inFifteenDate : tomorrow;

    return DateTime(firstDate.year, firstDate.month, firstDate.day);
  }

  DateTime _getInitialDateToUse(RepetitionCycleType cycle) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final inFifteenDate = DateUtils.getNextBiweeklyDate(now);

    final transactionDate = cycle == RepetitionCycleType.none
        ? now
        : cycle == RepetitionCycleType.biweekly ? inFifteenDate : tomorrow;

    return transactionDate;
  }
}

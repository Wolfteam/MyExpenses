import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/extensions/string_extensions.dart';
import '../../common/utils/app_path_utils.dart';
import '../../common/utils/category_utils.dart';
import '../../common/utils/date_utils.dart';
import '../../common/utils/transaction_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
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
  final UsersDao _usersDao;
  final SettingsService _settingsService;

  TransactionFormBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
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
      final transaction = await _transactionsDao.getTransaction(event.id);
      String imgPath = transaction.imagePath;

      bool imageExists = false;
      if (!transaction.imagePath.isNullEmptyOrWhitespace) {
        final user = await _usersDao.getActiveUser();
        imgPath = await AppPathUtils.buildUserImgPath(
          transaction.imagePath,
          user?.id,
        );
        imageExists = await File(imgPath).exists();
        if (!imageExists) {
          imgPath = null;
        }
      }

      final firstDate = _getFirstDateToUse(
        transaction.repetitionCycle,
        transaction.transactionDate,
      );

      yield TransactionFormLoadedState.initial(_settingsService.language)
          .copyWith(
        id: transaction.id,
        amount: transaction.amount,
        isAmountValid: true,
        isAmountDirty: true,
        category: transaction.category,
        isCategoryValid: true,
        description: transaction.description,
        isDescriptionValid: true,
        isDescriptionDirty: true,
        repetitionCycle: transaction.repetitionCycle,
        transactionDate: transaction.transactionDate,
        isTransactionDateValid: _isTransactionDateValid(
          transaction.transactionDate,
          transaction.repetitionCycle,
        ),
        isParentTransaction: transaction.isParentTransaction,
        parentTransactionId: transaction.parentTransactionId,
        firstDate: firstDate,
        imagePath: imgPath,
        imageExists: imageExists,
        isRecurringTransactionRunning: transaction.nextRecurringDate != null,
        nextRecurringDate: transaction.nextRecurringDate,
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
        isTransactionDateValid: _isTransactionDateValid(
          event.transactionDate,
          currentState.repetitionCycle,
        ),
      );
    }

    if (event is RepetitionCycleChanged) {
      final transactionDate = _getInitialDateToUse(event.repetitionCycle);
      final firstDate = _getFirstDateToUse(
        event.repetitionCycle,
        transactionDate,
      );

      yield currentState.copyWith(
        transactionDate: transactionDate,
        firstDate: firstDate,
        repetitionCycle: event.repetitionCycle,
        isTransactionDateValid: _isTransactionDateValid(
          transactionDate,
          event.repetitionCycle,
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

    if (event is IsRunningChanged) {
      yield* _isRunningChanged(event.isRunning);
    }

    if (event is DeleteTransaction) {
      yield* _deleteTransaction(currentState.id, event.keepChilds);
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
    final isAfter = date.isAfter(DateTime.now());
    return isAfter;
  }

  Stream<TransactionFormState> _saveTransaction() async* {
    try {
      yield currentState.copyWith(isSavingForm: true);

      String imgFilename;
      if (!currentState.imagePath.isNullEmptyOrWhitespace) {
        _logger.info(
          runtimeType,
          '_saveTransaction: Saving the image...',
        );
        final fileExists = await File(currentState.imagePath).exists();
        if (fileExists) {
          imgFilename = await _saveImage(currentState.imagePath);
        }
      }
      final transaction = currentState.buildTransactionItem(imgFilename);
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
    } catch (e, s) {
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

  Stream<TransactionFormState> _deleteTransaction(
    int id,
    bool keepChilds,
  ) async* {
    try {
      _logger.info(
        runtimeType,
        '_deleteTransaction: Getting transactionId = $id',
      );
      if (currentState.isParentTransaction) {
        _logger.info(
          runtimeType,
          '_deleteTransaction: Trying to delete parent transactionId = $id and childs = $keepChilds',
        );
        await _transactionsDao.deleteParentTransaction(
          id,
          keepChildTransactions: keepChilds,
        );
        yield TransactionChangedState.deleted(DateTime.now());
      } else {
        _logger.info(
          runtimeType,
          '_deleteTransaction: Trying to delete transactionId = $id',
        );
        final transToDelete = await _transactionsDao.getTransaction(id);
        await _transactionsDao.deleteTransaction(id);
        yield TransactionChangedState.deleted(transToDelete.transactionDate);
      }
    } catch (e, s) {
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

  Stream<TransactionFormState> _isRunningChanged(bool isRunning) async* {
    final now = DateTime.now();
    DateTime recurringDateTouse;

    try {
      _logger.info(
        runtimeType,
        '_isRunningChanged: Updating nextRecurringDate of ' +
            'transactionId = ${currentState.id}. IsNowRunning = $isRunning',
      );
      if (isRunning) {
        bool allCompleted = false;
        recurringDateTouse = currentState.transactionDate;
        while (!allCompleted) {
          if (recurringDateTouse.isAfter(now)) {
            allCompleted = true;
            break;
          }
          recurringDateTouse = TransactionUtils.getNextRecurringDate(
            currentState.repetitionCycle,
            recurringDateTouse,
          );
        }
      }

      _logger.info(
        runtimeType,
        '_isRunningChanged: The next recurringDate will be $recurringDateTouse',
      );

      await _transactionsDao.updateNextRecurringDate(
        currentState.id,
        recurringDateTouse,
      );
      yield currentState.copyWith(
        isRecurringTransactionRunning: isRunning,
        nextRecurringDate: recurringDateTouse,
        nextRecurringDateWasUpdated: true,
      );
      yield currentState.copyWith(
        isRecurringTransactionRunning: isRunning,
        nextRecurringDate: recurringDateTouse,
        nextRecurringDateWasUpdated: false,
      );
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_isRunningChanged: Unknown error occurred',
        e,
        s,
      );
    }
  }

  Future<String> _saveImage(String path) async {
    try {
      _logger.info(
        runtimeType,
        '_saveImage: Trying to save image',
      );
      final user = await _usersDao.getActiveUser();
      final finalPath = await AppPathUtils.generateTransactionImgPath(user?.id);

      await File(finalPath).writeAsBytes(await File(path).readAsBytes());

      _logger.info(
        runtimeType,
        '_saveImage: Image was successfully saved',
      );

      return basename(finalPath);
    } catch (e, s) {
      _logger.error(
        runtimeType,
        '_saveImage: Unknown error occurred:',
        e,
        s,
      );
      return null;
    }
  }

  DateTime _getFirstDateToUse(
    RepetitionCycleType cycle,
    DateTime transactionDate,
  ) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final inFifteenDate = DateUtils.getNextBiweeklyDate(now);

    final firstDate = cycle == RepetitionCycleType.none
        ? DateTime(now.year - 1)
        : cycle == RepetitionCycleType.biweekly ? inFifteenDate : tomorrow;

    final tentativeDate = DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day,
    );
    if (transactionDate.isBefore(tentativeDate)) return transactionDate;
    return tentativeDate;
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

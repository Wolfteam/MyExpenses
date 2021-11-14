import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' as material;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/extensions/string_extensions.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:my_expenses/presentation/shared/utils/category_utils.dart';
import 'package:path/path.dart';

part 'transaction_form_bloc.freezed.dart';
part 'transaction_form_event.dart';
part 'transaction_form_state.dart';

class TransactionFormBloc extends Bloc<TransactionFormEvent, TransactionFormState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final SettingsService _settingsService;
  final PathService _pathService;

  TransactionFormBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._settingsService,
    this._pathService,
  ) : super(const TransactionFormState.loading());

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<TransactionFormState> mapEventToState(
    TransactionFormEvent event,
  ) async* {
    try {
      if (event is _Submit) {
        yield currentState.copyWith(isSavingForm: true);
      }

      final s = await event.map(
        add: (_) async => _initialState(),
        edit: (e) async => _edit(e.id),
        amountChanged: (e) async => currentState.copyWith(amount: e.amount, isAmountValid: _isAmountValid(e.amount), isAmountDirty: true),
        descriptionChanged: (e) async => currentState.copyWith(
          description: e.description,
          isDescriptionValid: _isDescriptionValid(e.description),
          isDescriptionDirty: true,
        ),
        longDescriptionChanged: (e) async => currentState.copyWith(
          longDescription: e.longDescription,
          isDescriptionValid: _isLongDescriptionValid(e.longDescription),
          isDescriptionDirty: true,
        ),
        transactionDateChanged: (e) async {
          final transactionDateString = DateUtils.formatAppDate(
            e.transactionDate,
            _settingsService.getCurrentLanguageModel(),
            DateUtils.monthDayAndYearFormat,
          );
          return currentState.copyWith(
            transactionDate: e.transactionDate,
            isTransactionDateValid: _isTransactionDateValid(e.transactionDate, currentState.repetitionCycle),
            transactionDateString: transactionDateString,
          );
        },
        repetitionCycleChanged: (e) async {
          final transactionDate = _getInitialDateToUse(e.repetitionCycle);
          final transactionDateString = DateUtils.formatAppDate(
            transactionDate,
            _settingsService.getCurrentLanguageModel(),
            DateUtils.monthDayAndYearFormat,
          );
          final firstDate = _getFirstDateToUse(e.repetitionCycle, transactionDate);

          return currentState.copyWith(
            transactionDate: transactionDate,
            firstDate: firstDate,
            repetitionCycle: e.repetitionCycle,
            isTransactionDateValid: _isTransactionDateValid(transactionDate, e.repetitionCycle),
            transactionDateString: transactionDateString,
          );
        },
        categoryWasUpdated: (e) async => currentState.copyWith(category: e.category, isCategoryValid: true),
        imageChanged: (e) async => currentState.copyWith(imagePath: e.path, imageExists: e.imageExists),
        isRunningChanged: (e) async => _isRunningChanged(e.isRunning),
        deleteTransaction: (e) async => _deleteTransaction(currentState.id, e.keepChildren),
        submit: (e) async => _saveTransaction(),
        close: (_) async => _initialState(),
      );
      yield s;

      if (event is _IsRunningChanged) {
        yield currentState.copyWith(nextRecurringDateWasUpdated: false);
      }
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error', e, s);
      yield currentState.copyWith(errorOccurred: true, isSavingForm: false);
      yield currentState.copyWith(errorOccurred: false);
    }
  }

  _InitialState _initialState() {
    final cat = CategoryUtils.getByName(CategoryUtils.question);
    final category = CategoryItem(
      id: 0,
      isAnIncome: false,
      name: cat.name,
      icon: cat.icon.icon,
      iconColor: material.Colors.blue,
    );
    final language = _settingsService.language;
    final now = DateTime.now();
    final transactionDateString = DateUtils.formatAppDate(now, _settingsService.getCurrentLanguageModel(), DateUtils.monthDayAndYearFormat);

    return TransactionFormState.initial(
      id: 0,
      amount: 0,
      isAmountValid: false,
      isAmountDirty: false,
      description: '',
      isDescriptionValid: false,
      isDescriptionDirty: false,
      transactionDate: now,
      transactionDateString: transactionDateString,
      isTransactionDateValid: true,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      repetitionCycle: RepetitionCycleType.none,
      category: category,
      isCategoryValid: false,
      language: language,
      languageModel: _settingsService.getCurrentLanguageModel(),
      isLongDescriptionDirty: false,
      isLongDescriptionValid: true,
      longDescription: '',
    ) as _InitialState;
  }

  Future<_InitialState> _edit(int id) async {
    final transaction = await _transactionsDao.getTransaction(id);
    String? imgPath = transaction.imagePath;

    bool imageExists = false;
    if (!transaction.imagePath.isNullEmptyOrWhitespace) {
      final user = await _usersDao.getActiveUser();
      imgPath = await _pathService.buildUserImgPath(transaction.imagePath!, user?.id);
      imageExists = await File(imgPath).exists();
      if (!imageExists) {
        imgPath = null;
      }
    }

    final initialState = _initialState();
    final firstDate = _getFirstDateToUse(transaction.repetitionCycle, transaction.transactionDate);
    final transactionDateString = DateUtils.formatAppDate(
      transaction.transactionDate,
      _settingsService.getCurrentLanguageModel(),
      DateUtils.monthDayAndYearFormat,
    );
    return initialState.copyWith(
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
      transactionDateString: transactionDateString,
      isTransactionDateValid: _isTransactionDateValid(transaction.transactionDate, transaction.repetitionCycle),
      isParentTransaction: transaction.isParentTransaction,
      parentTransactionId: transaction.parentTransactionId,
      firstDate: firstDate,
      imagePath: imgPath,
      imageExists: imageExists,
      isRecurringTransactionRunning: transaction.nextRecurringDate != null,
      nextRecurringDate: transaction.nextRecurringDate,
      longDescription: transaction.longDescription,
    );
  }

  bool _isAmountValid(double amount) => amount != 0;

  bool _isDescriptionValid(String description) => !description.isNullOrEmpty(minLength: 1);

  bool _isLongDescriptionValid(String description) => description.isNullEmptyOrWhitespace || !description.isNullOrEmpty(minLength: 1, maxLength: 500);

  bool _isTransactionDateValid(DateTime date, RepetitionCycleType cycle) {
    if (cycle == RepetitionCycleType.none) return true;
    final isAfter = date.isAfter(DateTime.now());
    return isAfter;
  }

  Future<TransactionFormState> _saveTransaction() async {
    try {
      String? imgFilename;
      if (!currentState.imagePath.isNullEmptyOrWhitespace) {
        _logger.info(runtimeType, '_saveTransaction: Saving the image...');
        final fileExists = await File(currentState.imagePath!).exists();
        if (fileExists) {
          imgFilename = await _saveImage(currentState.imagePath!);
        }
      }

      final transaction = _toTransactionItem(imgFilename);
      _logger.info(runtimeType, '_saveTransaction: Trying to save transaction = ${transaction.toJson()}');

      final createdTrans = await _transactionsDao.saveTransaction(transaction);

      if (TransactionFormState.isNewTransaction(currentState)) {
        return TransactionFormState.created(createdTrans.transactionDate);
      }
      return TransactionFormState.updated(createdTrans.transactionDate);
    } catch (e, s) {
      _logger.error(runtimeType, '_saveTransaction: Unknown error occurred:', e, s);
      rethrow;
    }
  }

  Future<TransactionFormState> _deleteTransaction(int id, bool keepChildren) async {
    try {
      _logger.info(runtimeType, '_deleteTransaction: Getting transactionId = $id');
      if (currentState.isParentTransaction) {
        _logger.info(
          runtimeType,
          '_deleteTransaction: Trying to delete parent transactionId = $id and children = $keepChildren',
        );
        await _transactionsDao.deleteParentTransaction(id, keepChildTransactions: keepChildren);
        return TransactionFormState.deleted(DateTime.now());
      }
      _logger.info(runtimeType, '_deleteTransaction: Trying to delete transactionId = $id');
      final transToDelete = await _transactionsDao.getTransaction(id);
      await _transactionsDao.deleteTransaction(id);
      return TransactionFormState.deleted(transToDelete.transactionDate);
    } catch (e, s) {
      _logger.error(runtimeType, '_deleteTransaction: Unknown error occurred', e, s);
      rethrow;
    }
  }

  Future<TransactionFormState> _isRunningChanged(bool isRunning) async {
    final now = DateTime.now();
    DateTime? recurringDateToUse;

    try {
      _logger.info(
        runtimeType,
        '_isRunningChanged: Updating nextRecurringDate of ' + 'transactionId = ${currentState.id}. IsNowRunning = $isRunning',
      );
      if (isRunning) {
        bool allCompleted = false;
        recurringDateToUse = currentState.transactionDate;
        while (!allCompleted) {
          if (recurringDateToUse!.isAfter(now)) {
            allCompleted = true;
            break;
          }
          recurringDateToUse = TransactionUtils.getNextRecurringDate(currentState.repetitionCycle, recurringDateToUse);
        }
      }

      _logger.info(runtimeType, '_isRunningChanged: The next recurringDate will be $recurringDateToUse');

      await _transactionsDao.updateNextRecurringDate(currentState.id, recurringDateToUse);
      return currentState.copyWith(
        isRecurringTransactionRunning: isRunning,
        nextRecurringDate: recurringDateToUse,
        nextRecurringDateWasUpdated: true,
      );
    } catch (e, s) {
      _logger.error(runtimeType, '_isRunningChanged: Unknown error occurred', e, s);
      rethrow;
    }
  }

  Future<String?> _saveImage(String path) async {
    try {
      _logger.info(runtimeType, '_saveImage: Trying to save image');
      final user = await _usersDao.getActiveUser();
      final finalPath = await _pathService.generateTransactionImgPath(user?.id);

      await _pathService.moveFile(path, finalPath);

      _logger.info(runtimeType, '_saveImage: Image was successfully saved');

      return basename(finalPath);
    } catch (e, s) {
      _logger.error(runtimeType, '_saveImage: Unknown error occurred:', e, s);
      return null;
    }
  }

  DateTime _getFirstDateToUse(RepetitionCycleType cycle, DateTime transactionDate) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final inFifteenDate = DateUtils.getNextBiweeklyDate(now);

    final firstDate = cycle == RepetitionCycleType.none
        ? DateTime(now.year - 1)
        : cycle == RepetitionCycleType.biweekly
            ? inFifteenDate
            : tomorrow;

    final tentativeDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    if (transactionDate.isBefore(tentativeDate)) return transactionDate;
    return tentativeDate;
  }

  DateTime _getInitialDateToUse(RepetitionCycleType cycle) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final inFifteenDate = DateUtils.getNextBiweeklyDate(now);

    final transactionDate = cycle == RepetitionCycleType.none
        ? now
        : cycle == RepetitionCycleType.biweekly
            ? inFifteenDate
            : tomorrow;

    return transactionDate;
  }

  TransactionItem _toTransactionItem(String? imgFilename) {
    final amountToSave = currentState.amount.abs();
    final nextRecurringDate =
        currentState.repetitionCycle == RepetitionCycleType.none || !currentState.isRecurringTransactionRunning ? null : currentState.transactionDate;
    final isParentTransaction = nextRecurringDate != null;

    return TransactionItem(
      id: currentState.id,
      amount: currentState.category.isAnIncome ? amountToSave : amountToSave * -1,
      category: currentState.category,
      description: currentState.description.trim(),
      repetitionCycle: currentState.repetitionCycle,
      transactionDate: currentState.transactionDate,
      isParentTransaction: isParentTransaction,
      parentTransactionId: currentState.parentTransactionId,
      nextRecurringDate: nextRecurringDate,
      imagePath: imgFilename,
      longDescription: currentState.longDescription,
    );
  }
}

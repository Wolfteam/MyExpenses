import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/drive.dart';
import 'package:my_expenses/domain/models/entities/daos/categories_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'data_transfer_bloc.freezed.dart';
part 'data_transfer_event.dart';
part 'data_transfer_state.dart';

class DataTransferBloc extends Bloc<DataTransferEvent, DataTransferState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final CategoriesDao _categoriesDao;
  final PaymentMethodsDao _paymentMethodsDao;
  final UsersDao _usersDao;

  DataTransferBloc(
    this._logger,
    this._transactionsDao,
    this._categoriesDao,
    this._paymentMethodsDao,
    this._usersDao,
  ) : super(const DataTransferState.idle()) {
    on<DataTransferEventExport>(_onExport);
    on<DataTransferEventImport>(_onImport);
    on<DataTransferEventClearAll>(_onClearAll);
  }

  Future<void> _onExport(
    DataTransferEventExport event,
    Emitter<DataTransferState> emit,
  ) async {
    emit(const DataTransferState.loading());
    try {
      final user = await _usersDao.getActiveUser();
      final userId = user?.id;

      final transactions = await _transactionsDao.getAllTransactionsToSync(userId);
      final paymentMethods = await _paymentMethodsDao.getAllPaymentMethodsToSync(userId);
      final categories = await _categoriesDao.getAllCategoriesToSync(userId);

      final appFile = AppFile(
        transactions: transactions,
        categories: categories,
        paymentMethods: paymentMethods,
      );

      final docsDir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory(p.join(docsDir.path, 'MyExpenses', 'exports'));
      await exportsDir.create(recursive: true);

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());

      if (event.isCsv) {
        // Build a category lookup by createdHash
        final categoryLookup = {
          for (final c in appFile.categories) c.createdHash: c,
        };
        // Build a payment method lookup by createdHash
        final pmLookup = {
          for (final pm in appFile.paymentMethods) pm.createdHash: pm,
        };

        final labels = event.csvLabels!;
        final rows = <List<dynamic>>[
          [
            labels.date,
            labels.description,
            labels.amount,
            labels.category,
            labels.type,
            labels.paymentMethod,
            labels.longDescription,
            labels.repetitionCycle,
            labels.isRecurring,
          ],
          for (final t in appFile.transactions)
            [
              DateFormat('yyyy-MM-dd').format(t.transactionDate),
              t.description,
              t.amount,
              categoryLookup[t.categoryCreatedHash]?.name ?? '',
              if (categoryLookup[t.categoryCreatedHash]?.isAnIncome ?? false) labels.income else labels.expense,
              t.paymentMethodName ?? pmLookup[t.paymentMethodCreatedHash]?.name ?? '',
              t.longDescription ?? '',
              switch (t.repetitionCycle) {
                RepetitionCycleType.none => labels.repetitionCycleNone,
                RepetitionCycleType.eachDay => labels.repetitionCycleEachDay,
                RepetitionCycleType.eachWeek => labels.repetitionCycleEachWeek,
                RepetitionCycleType.eachMonth => labels.repetitionCycleEachMonth,
                RepetitionCycleType.biweekly => labels.repetitionCycleBiweekly,
                RepetitionCycleType.eachYear => labels.repetitionCycleEachYear,
              },
              if (t.isParentTransaction) labels.yes else t.parentTransactionCreatedHash != null ? labels.auto : labels.no,
            ],
        ];

        final csvString = const ListToCsvConverter().convert(rows);
        final filePath = p.join(
          exportsDir.path,
          'my_expenses_export_$timestamp.csv',
        );
        await File(filePath).writeAsString(csvString);
      } else {
        final filePath = p.join(
          exportsDir.path,
          'my_expenses_export_$timestamp.json',
        );
        await File(filePath).writeAsString(jsonEncode(appFile.toJson()));
      }

      await OpenFilex.open(exportsDir.path);
      emit(const DataTransferState.success(operation: DataTransferOperation.export));
    } catch (e, s) {
      _logger.error(runtimeType, '_onExport: error', e, s);
      emit(const DataTransferState.error(operation: DataTransferOperation.export));
    }
  }

  Future<void> _onImport(
    DataTransferEventImport event,
    Emitter<DataTransferState> emit,
  ) async {
    emit(const DataTransferState.loading());
    try {
      final content = await File(event.filePath).readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final validationError = _validate(json);
      if (validationError != null) {
        emit(DataTransferState.importValidationError(validationError: validationError));
        return;
      }

      final appFile = AppFile.fromJson(json);
      final user = await _usersDao.getActiveUser();
      final userId = user?.id;

      // Delete order: transactions → categories → payment methods (FK constraints)
      await _transactionsDao.deleteAll(userId);
      await _categoriesDao.deleteAll(userId);
      await _paymentMethodsDao.deleteAll(userId);

      // Insert order: categories → payment methods → transactions
      await _categoriesDao.syncDownCreate(userId, appFile.categories);
      await _paymentMethodsDao.syncDownCreate(userId, appFile.paymentMethods);
      await _transactionsDao.syncDownCreate(userId, appFile.transactions);

      emit(const DataTransferState.success(operation: DataTransferOperation.import));
    } catch (e, s) {
      _logger.error(runtimeType, '_onImport: error', e, s);
      emit(const DataTransferState.error(operation: DataTransferOperation.import));
    }
  }

  Future<void> _onClearAll(
    DataTransferEventClearAll event,
    Emitter<DataTransferState> emit,
  ) async {
    emit(const DataTransferState.loading());
    try {
      final user = await _usersDao.getActiveUser();
      final userId = user?.id;
      // Delete order: transactions → categories → payment methods
      await _transactionsDao.deleteAll(userId);
      await _categoriesDao.deleteAll(userId);
      await _paymentMethodsDao.deleteAll(userId);
      emit(const DataTransferState.success(operation: DataTransferOperation.clearAll));
    } catch (e, s) {
      _logger.error(runtimeType, '_onClearAll: error', e, s);
      emit(const DataTransferState.error(operation: DataTransferOperation.clearAll));
    }
  }

  ImportValidationError? _validate(Map<String, dynamic> json) {
    if (!json.containsKey('transactions') || json['transactions'] is! List) {
      return const ImportValidationError.invalidFormat();
    }
    if (!json.containsKey('categories') || json['categories'] is! List) {
      return const ImportValidationError.invalidFormat();
    }
    final transactions = json['transactions'] as List;
    for (final t in transactions) {
      if (t is! Map<String, dynamic>) return const ImportValidationError.invalidFormat();
      for (final field in Transaction.requiredJsonFields) {
        if (!t.containsKey(field)) return ImportValidationError.missingField(field: field);
      }
    }
    final categories = json['categories'] as List;
    for (final c in categories) {
      if (c is! Map<String, dynamic>) return const ImportValidationError.invalidFormat();
      for (final field in Category.requiredJsonFields) {
        if (!c.containsKey(field)) return ImportValidationError.missingField(field: field);
      }
    }
    if (json.containsKey('paymentMethods')) {
      if (json['paymentMethods'] is! List) {
        return const ImportValidationError.invalidFormat();
      }
      final paymentMethods = json['paymentMethods'] as List;
      for (final p in paymentMethods) {
        if (p is! Map<String, dynamic>) return const ImportValidationError.invalidFormat();
        for (final field in PaymentMethod.requiredJsonFields) {
          if (!p.containsKey(field)) return ImportValidationError.missingField(field: field);
        }
      }
    }
    return null;
  }
}

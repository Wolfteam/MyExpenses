import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../common/enums/report_file_type.dart';
import '../../common/utils/app_path_utils.dart';
import '../../common/utils/date_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../generated/i18n.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
import '../../ui/widgets/reports/pdf_report.dart';
import '../currency/currency_bloc.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final UsersDao _usersDao;
  final CurrencyBloc _currencyBloc;

  ReportsBloc(
    this._logger,
    this._transactionsDao,
    this._usersDao,
    this._currencyBloc,
  ) : super(ReportSheetState.initial());

  ReportSheetState get currentState => state as ReportSheetState;

  @override
  Stream<ReportState> mapEventToState(
    ReportsEvent event,
  ) async* {
    if (event is ResetReportSheet) {
      yield ReportSheetState.initial();
    }

    if (event is FromDateChanged) {
      var from = event.selectedDate;
      final to = currentState.to;
      if (from.isAfter(to)) {
        from = to.add(const Duration(days: -1));
      }

      yield currentState.copyWith(from: from, to: to);
    }

    if (event is ToDateChanged) {
      var from = currentState.from;
      if (event.selectedDate.isBefore(from)) {
        from = event.selectedDate.add(const Duration(days: -1));
      }
      yield currentState.copyWith(from: from, to: event.selectedDate);
    }

    if (event is FileTypeChanged) {
      yield currentState.copyWith(selectedFileType: event.selectedFileType);
    }

    if (event is GenerateReport) {
      yield* _buildReport(event);
    }
  }

  Stream<ReportState> _buildReport(GenerateReport event) async* {
    try {
      yield currentState.copyWith(generatingReport: true);

      final currentUser = await _usersDao.getActiveUser();
      final transactions = await _transactionsDao.getAllTransactions(
        currentUser?.id,
        currentState.from,
        currentState.to,
      );
      transactions.sort(
        (t1, t2) => t1.transactionDate.compareTo(t2.transactionDate),
      );

      String path;
      if (currentState.selectedFileType == ReportFileType.csv) {
        path = await _buildCsvReport(transactions, event);
      } else {
        path = await _buildPdfReport(transactions, event);
      }
      final filename = basename(path);
      yield ReportGeneratedState(filename, path);
    } catch (e, s) {
      _logger.error(runtimeType, '_buildReport: Unknown error occurred', e, s);
      yield currentState.copyWith(errorOccurred: true, generatingReport: false);
      yield currentState.copyWith(
        errorOccurred: false,
        generatingReport: false,
      );
    }
  }

  Future<String> _buildCsvReport(
    List<TransactionItem> transactions,
    GenerateReport event,
  ) async {
    final csvData = [
      <String>[
        event.i18n.id,
        event.i18n.description,
        event.i18n.amount,
        event.i18n.date,
        event.i18n.categoryName,
        event.i18n.type
      ],
      ...transactions.map((t) => [
            t.id,
            t.description,
            _currencyBloc.format(t.amount),
            DateUtils.formatDateWithoutLocale(
              t.transactionDate,
              DateUtils.monthDayAndYearFormat,
            ),
            t.category.name,
            if (t.category.isAnIncome) event.i18n.income else event.i18n.expense,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);

    final path = await AppPathUtils.generateReportFilePath(isPdf: false);
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  Future<String> _buildPdfReport(
    List<TransactionItem> transactions,
    GenerateReport event,
  ) async {
    final pdf = await buildPdf(
      (amount) => _currencyBloc.format(amount),
      transactions,
      event.i18n,
      currentState.from,
      currentState.to,
    );

    final path = await AppPathUtils.generateReportFilePath();
    final file = File(path);
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    return path;
  }
}

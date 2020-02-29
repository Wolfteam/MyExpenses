import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/enums/report_file_type.dart';
import '../../common/utils/date_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../generated/i18n.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
import '../../ui/widgets/reports/pdf_report.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;

  ReportsBloc(this._logger, this._transactionsDao);

  @override
  ReportState get initialState => ReportSheetState.initial();

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
      final transactions = await _transactionsDao.getAllTransactions(
        currentState.from,
        currentState.to,
      );
      transactions
          .sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));
      final dir = await getExternalStorageDirectory();

      if (currentState.selectedFileType == ReportFileType.csv) {
        final path = await _buildCsvReport(dir, transactions, event);
        yield ReportGeneratedState(path);
      } else {
        final path = await _buildPdfReport(dir, transactions, event);
        yield ReportGeneratedState(path);
      }
    } on Exception catch (e, s) {
      _logger.error(runtimeType, '_buildReport: Unknown error occurred', e, s);
      yield currentState.copyWith(errorOccurred: true);
      yield currentState.copyWith(errorOccurred: false);
    }
  }

  Future<String> _buildCsvReport(
    Directory dir,
    List<TransactionItem> transactions,
    GenerateReport event,
  ) async {
    final now = DateTime.now();
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
            t.amount.toString(),
            t.transactionDate.toString(),
            t.category.name,
            if (t.category.isAnIncome)
              event.i18n.income
            else
              event.i18n.expense,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);

    final path = '${dir.path}/report_$now.csv';

    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  Future<String> _buildPdfReport(
    Directory dir,
    List<TransactionItem> transactions,
    GenerateReport event,
  ) async {
    final now = DateTime.now();
    final pdf = await buildPdf(
      transactions,
      event.i18n,
      currentState.from,
      currentState.to,
    );
    final path = '${dir.path}/report_$now.pdf';
    final file = File(path);
    await file.writeAsBytes(pdf.save());

    return path;
  }
}

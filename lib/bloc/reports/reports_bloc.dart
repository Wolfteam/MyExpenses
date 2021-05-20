import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/common/utils/app_path_utils.dart';
import 'package:my_expenses/generated/l10n.dart';
import 'package:my_expenses/models/transaction_item.dart';
import 'package:my_expenses/ui/widgets/reports/pdf_report.dart';
import 'package:path/path.dart';

import '../../common/enums/report_file_type.dart';
import '../../common/utils/date_utils.dart';
import '../../daos/transactions_dao.dart';
import '../../daos/users_dao.dart';
import '../../services/logging_service.dart';
import '../currency/currency_bloc.dart';

part 'reports_bloc.freezed.dart';
part 'reports_event.dart';
part 'reports_state.dart';

final _initialState = ReportState.initial(
  selectedFileType: ReportFileType.pdf,
  from: DateUtils.getFirstDayDateOfTheMonth(DateTime.now()),
  to: DateTime.now(),
);

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
  ) : super(_initialState);

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<ReportState> mapEventToState(
    ReportsEvent event,
  ) async* {
    try {
      final s = await event.map(
        resetReportSheet: (_) async => _initialState,
        fromDateChanged: (e) async {
          var from = e.selectedDate;
          final to = currentState.to;
          if (from.isAfter(to)) {
            from = to.add(const Duration(days: -1));
          }

          return currentState.copyWith(from: from, to: to);
        },
        toDateChanged: (e) async {
          var from = currentState.from;
          if (e.selectedDate.isBefore(from)) {
            from = e.selectedDate.add(const Duration(days: -1));
          }
          return currentState.copyWith(from: from, to: e.selectedDate);
        },
        fileTypeChanged: (e) async => currentState.copyWith(selectedFileType: e.selectedFileType),
        generateReport: (e) async => _buildReport(e.i18n),
      );

      if (event is _GenerateReport) {
        yield currentState.copyWith(generatingReport: true);
      }

      yield s;
    } catch (e, s) {
      _logger.error(runtimeType, 'Unknown error occurred', e, s);
      yield currentState.copyWith(errorOccurred: true, generatingReport: false);
      yield currentState.copyWith(errorOccurred: false, generatingReport: false);
    }
  }

  Future<ReportState> _buildReport(S i18n) async {
    final currentUser = await _usersDao.getActiveUser();
    final transactions = await _transactionsDao.getAllTransactions(
      currentUser?.id,
      currentState.from,
      currentState.to,
    );
    transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

    String path;
    if (currentState.selectedFileType == ReportFileType.csv) {
      path = await _buildCsvReport(transactions, i18n);
    } else {
      path = await _buildPdfReport(transactions, i18n);
    }
    final filename = basename(path);
    return ReportState.generated(fileName: filename, filePath: path, selectedFileType: currentState.selectedFileType);
  }

  Future<String> _buildCsvReport(
    List<TransactionItem> transactions,
    S i18n,
  ) async {
    final csvData = [
      <String>[i18n.id, i18n.description, i18n.amount, i18n.date, i18n.categoryName, i18n.type],
      ...transactions.map((t) => [
            t.id,
            t.description,
            _currencyBloc.format(t.amount),
            DateUtils.formatDateWithoutLocale(
              t.transactionDate,
              DateUtils.monthDayAndYearFormat,
            ),
            t.category.name,
            if (t.category.isAnIncome) i18n.income else i18n.expense,
          ]),
    ];

    final csv = const ListToCsvConverter().convert(csvData);

    final path = await AppPathUtils.generateReportFilePath(isPdf: false);
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  Future<String> _buildPdfReport(List<TransactionItem> transactions, S i18n) async {
    final pdf = await buildPdf(
      (amount) => _currencyBloc.format(amount),
      transactions,
      i18n,
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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/transactions_dao.dart';
import 'package:my_expenses/domain/models/entities/daos/users_dao.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/services/services.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/presentation/reports/pdf_report.dart';
import 'package:path/path.dart';

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
  final PathService _pathService;
  final NotificationService _notificationService;
  final DeviceInfoService _deviceInfoService;
  final UsersDao _usersDao;
  final CurrencyBloc _currencyBloc;

  ReportsBloc(
    this._logger,
    this._transactionsDao,
    this._pathService,
    this._notificationService,
    this._deviceInfoService,
    this._usersDao,
    this._currencyBloc,
  ) : super(_initialState);

  _InitialState get currentState => state as _InitialState;

  @override
  Stream<ReportState> mapEventToState(ReportsEvent event) async* {
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
        generateReport: (e) async => _buildReport(e.translations),
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

  Future<ReportState> _buildReport(ReportTranslations translations) async {
    final currentUser = await _usersDao.getActiveUser();
    final transactions = await _transactionsDao.getAllTransactions(
      currentUser?.id,
      currentState.from,
      currentState.to,
    );
    transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

    String path;
    if (currentState.selectedFileType == ReportFileType.csv) {
      path = await _buildCsvReport(transactions, translations);
    } else {
      path = await _buildPdfReport(transactions, translations);
    }
    final filename = basename(path);
    await __showNotification(filename, path, translations);
    return ReportState.generated(fileName: filename, filePath: path, selectedFileType: currentState.selectedFileType);
  }

  Future<String> _buildCsvReport(List<TransactionItem> transactions, ReportTranslations translations) async {
    final csvData = [
      <String>[translations.id, translations.description, translations.amount, translations.date, translations.category, translations.type],
      ...transactions.map(
        (t) => [
          t.id,
          t.description,
          _currencyBloc.format(t.amount),
          DateUtils.formatDateWithoutLocale(t.transactionDate, DateUtils.monthDayAndYearFormat),
          t.category.name,
          if (t.category.isAnIncome) translations.income else translations.expense,
        ],
      ),
    ];

    final csv = const ListToCsvConverter().convert(csvData);

    final path = await _pathService.generateReportFilePath(isPdf: false);
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }

  //TODO: REMOVE THE BUILD PDF AND CSV FROM HERE?
  Future<String> _buildPdfReport(List<TransactionItem> transactions, ReportTranslations translations) async {
    final pdf = await buildPdf(
      (amount) => _currencyBloc.format(amount),
      transactions,
      translations,
      currentState.from,
      currentState.to,
      _deviceInfoService.appName,
      _deviceInfoService.version,
    );

    final path = await _pathService.generateReportFilePath();
    final file = File(path);
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    return path;
  }

  Future<void> __showNotification(String filename, String filePath, ReportTranslations translations) async {
    final notificationType = state.selectedFileType == ReportFileType.pdf ? NotificationType.openPdf : NotificationType.openCsv;
    final json = jsonEncode(AppNotification.openFile(filePath, notificationType));
    await _notificationService.showNotificationWithoutId(
      AppNotificationType.reports,
      translations.transactionsReport,
      '${translations.reportWasSuccessfullyGenerated(filename)}.\n${translations.tapToOpen}',
      payload: json,
    );
  }
}

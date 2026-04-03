import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:csv/csv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/application/bloc.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/entities/daos/payment_methods_dao.dart';
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
  selectedPaymentMethodId: null,
  groupByPaymentMethod: false,
);

class ReportsBloc extends Bloc<ReportsEvent, ReportState> {
  final LoggingService _logger;
  final TransactionsDao _transactionsDao;
  final PathService _pathService;
  final NotificationService _notificationService;
  final DeviceInfoService _deviceInfoService;
  final UsersDao _usersDao;
  final CurrencyBloc _currencyBloc;
  final PaymentMethodsDao _paymentMethodsDao;

  ReportsBloc(
    this._logger,
    this._transactionsDao,
    this._pathService,
    this._notificationService,
    this._deviceInfoService,
    this._usersDao,
    this._currencyBloc,
    this._paymentMethodsDao,
  ) : super(_initialState) {
    on<ReportsEventResetReportSheet>((event, emit) {
      emit(_initialState);
    });

    on<ReportsEventFromDateChanged>((event, emit) {
      var from = event.selectedDate;
      final to = currentState.to;
      if (from.isAfter(to)) {
        from = to.add(const Duration(days: -1));
      }

      final s = currentState.copyWith(from: from, to: to);
      emit(s);
    });

    on<ReportsEventToDateChanged>((event, emit) {
      var from = currentState.from;
      if (event.selectedDate.isBefore(from)) {
        from = event.selectedDate.add(const Duration(days: -1));
      }
      final s = currentState.copyWith(from: from, to: event.selectedDate);
      emit(s);
    });

    on<ReportsEventFileTypeChanged>((event, emit) {
      final s = currentState.copyWith(selectedFileType: event.selectedFileType);
      emit(s);
    });

    on<ReportsEventPaymentMethodChanged>((event, emit) {
      final s = currentState.copyWith(selectedPaymentMethodId: event.selectedPaymentMethodId);
      emit(s);
    });

    on<ReportsEventGroupByPaymentMethodChanged>((event, emit) {
      final s = currentState.copyWith(groupByPaymentMethod: event.value);
      emit(s);
    });

    on<ReportsEventGenerateReport>((event, emit) async {
      try {
        emit(currentState.copyWith(generatingReport: true));
        final s = await _buildReport(event.translations);
        emit(s);
      } catch (e, s) {
        _logger.error(runtimeType, 'Unknown error occurred', e, s);
        emit(currentState.copyWith(errorOccurred: true, generatingReport: false));
        emit(currentState.copyWith(errorOccurred: false, generatingReport: false));
      }
    });
  }

  ReportStateInitialState get currentState => state as ReportStateInitialState;

  Future<ReportState> _buildReport(ReportTranslations translations) async {
    final currentUser = await _usersDao.getActiveUser();
    final transactions = await _transactionsDao.getAllTransactions(
      currentUser?.id,
      currentState.from,
      currentState.to,
      paymentMethodId: currentState.selectedPaymentMethodId,
    );
    transactions.sort((t1, t2) => t1.transactionDate.compareTo(t2.transactionDate));

    String path;
    // Build payment method id->name map when needed (include archived)
    final pmList = currentUser != null
        ? await _paymentMethodsDao.getAll(currentUser.id, includeArchived: true)
        : <PaymentMethodItem>[];
    final pmNames = {for (final m in pmList) m.id: m.name};

    if (currentState.selectedFileType == ReportFileType.csv) {
      path = await _buildCsvReport(transactions, translations, pmNames);
    } else {
      path = await _buildPdfReport(
        transactions,
        translations,
        groupByPaymentMethod: currentState.groupByPaymentMethod,
        paymentMethodNames: pmNames,
      );
    }
    final filename = basename(path);
    await __showNotification(filename, path, translations);
    return ReportState.generated(fileName: filename, filePath: path, selectedFileType: currentState.selectedFileType);
  }

  Future<String> _buildCsvReport(
    List<TransactionItem> transactions,
    ReportTranslations translations,
    Map<int, String> pmNames,
  ) async {
    final csvData = [
      <String>[
        translations.id,
        translations.description,
        translations.amount,
        translations.date,
        translations.category,
        translations.type,
        translations.paymentMethod,
      ],
      ...transactions.map(
        (t) => [
          t.id,
          t.description,
          _currencyBloc.format(t.amount),
          DateUtils.formatDateWithoutLocale(t.transactionDate, DateUtils.monthDayAndYearFormat),
          t.category.name,
          if (t.category.isAnIncome) translations.income else translations.expense,
          t.paymentMethodId != null ? (pmNames[t.paymentMethodId!] ?? translations.unknown) : translations.unknown,
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
  Future<String> _buildPdfReport(
    List<TransactionItem> transactions,
    ReportTranslations translations, {
    bool groupByPaymentMethod = false,
    Map<int, String>? paymentMethodNames,
  }) async {
    final pdf = await buildPdf(
      (amount) => _currencyBloc.format(amount),
      transactions,
      translations,
      currentState.from,
      currentState.to,
      _deviceInfoService.appName,
      _deviceInfoService.version,
      groupByPaymentMethod: groupByPaymentMethod,
      paymentMethodNames: paymentMethodNames,
      unknownPaymentMethodLabel: translations.unknown,
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

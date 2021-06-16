part of 'reports_bloc.dart';

@freezed
class ReportsEvent with _$ReportsEvent {
  const factory ReportsEvent.resetReportSheet() = _ResetReportSheet;

  const factory ReportsEvent.fromDateChanged({
    required DateTime selectedDate,
  }) = _FromDateChanged;

  const factory ReportsEvent.toDateChanged({
    required DateTime selectedDate,
  }) = _ToDateChanged;

  const factory ReportsEvent.fileTypeChanged({
    required ReportFileType selectedFileType,
  }) = _FileTypeChanged;

  const factory ReportsEvent.generateReport({
    required S i18n,
  }) = _GenerateReport;
}

part of 'reports_bloc.dart';

@freezed
sealed class ReportsEvent with _$ReportsEvent {
  const factory ReportsEvent.resetReportSheet() = ReportsEventResetReportSheet;

  const factory ReportsEvent.fromDateChanged({required DateTime selectedDate}) = ReportsEventFromDateChanged;

  const factory ReportsEvent.toDateChanged({required DateTime selectedDate}) = ReportsEventToDateChanged;

  const factory ReportsEvent.fileTypeChanged({required ReportFileType selectedFileType}) = ReportsEventFileTypeChanged;

  const factory ReportsEvent.generateReport({required ReportTranslations translations}) = ReportsEventGenerateReport;
}

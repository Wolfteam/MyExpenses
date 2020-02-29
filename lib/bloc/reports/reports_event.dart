part of 'reports_bloc.dart';

abstract class ReportsEvent extends Equatable {
  @override
  List<Object> get props => [];
  const ReportsEvent();
}

class ResetReportSheet extends ReportsEvent {
  const ResetReportSheet();
}

class FromDateChanged extends ReportsEvent {
  final DateTime selectedDate;
  @override
  List<Object> get props => [selectedDate];

  const FromDateChanged(this.selectedDate);
}

class ToDateChanged extends ReportsEvent {
  final DateTime selectedDate;
  @override
  List<Object> get props => [selectedDate];

  const ToDateChanged(this.selectedDate);
}

class FileTypeChanged extends ReportsEvent {
  final ReportFileType selectedFileType;
  @override
  List<Object> get props => [selectedFileType];

  const FileTypeChanged(this.selectedFileType);
}

class GenerateReport extends ReportsEvent {
  final I18n i18n;

  @override
  List<Object> get props => [i18n];

  const GenerateReport(
    this.i18n,
  );
}

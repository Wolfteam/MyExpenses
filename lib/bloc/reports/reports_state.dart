part of 'reports_bloc.dart';

@freezed
class ReportState with _$ReportState {
  //TODO: THIS
  // String get fromDateString => DateUtils.formatDateWithoutLocale(from, DateUtils.monthDayAndYearFormat);
  //
  // String get toDateString => DateUtils.formatDateWithoutLocale(to, DateUtils.monthDayAndYearFormat);
  //
  // const ReportState._();

  const factory ReportState.initial({
    required ReportFileType selectedFileType,
    required DateTime from,
    required DateTime to,
    @Default(false) bool errorOccurred,
    @Default(false) bool generatingReport,
  }) = _InitialState;

  const factory ReportState.generated({
    required String fileName,
    required String filePath,
  }) = _GeneratedState;
}

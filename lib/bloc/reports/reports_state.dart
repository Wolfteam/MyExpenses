part of 'reports_bloc.dart';

@freezed
class ReportState with _$ReportState {
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
    required ReportFileType selectedFileType,
  }) = _GeneratedState;
}

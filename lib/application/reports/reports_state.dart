part of 'reports_bloc.dart';

@freezed
sealed class ReportState with _$ReportState {
  const factory ReportState.initial({
    required ReportFileType selectedFileType,
    required DateTime from,
    required DateTime to,
    @Default(false) bool errorOccurred,
    @Default(false) bool generatingReport,
  }) = ReportStateInitialState;

  const factory ReportState.generated({
    required String fileName,
    required String filePath,
    required ReportFileType selectedFileType,
  }) = ReportStateGeneratedState;
}

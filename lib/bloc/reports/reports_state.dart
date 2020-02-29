part of 'reports_bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();
}

class ReportSheetState extends ReportState {
  final ReportFileType selectedFileType;
  final DateTime from;
  final DateTime to;
  final bool errorOccurred;

  String get fromDateString =>
      DateUtils.formatDateWithoutLocale(from, DateUtils.monthDayAndYearFormat);
  String get toDateString =>
      DateUtils.formatDateWithoutLocale(to, DateUtils.monthDayAndYearFormat);

  @override
  List<Object> get props => [
        selectedFileType,
        from,
        to,
        errorOccurred,
      ];

  const ReportSheetState({
    @required this.selectedFileType,
    @required this.from,
    @required this.to,
    this.errorOccurred = false,
  });

  factory ReportSheetState.initial() {
    final now = DateTime.now();
    final from = DateUtils.getFirstDayDateOfTheMonth(now);
    return ReportSheetState(
      selectedFileType: ReportFileType.csv,
      from: from,
      to: now,
    );
  }

  ReportSheetState copyWith({
    ReportFileType selectedFileType,
    DateTime from,
    DateTime to,
    bool errorOccurred,
  }) {
    return ReportSheetState(
      selectedFileType: selectedFileType ?? this.selectedFileType,
      from: from ?? this.from,
      to: to ?? this.to,
      errorOccurred: errorOccurred ?? this.errorOccurred,
    );
  }
}

class ReportGeneratedState extends ReportState {
  final String fileName;
  final String filePath;

  @override
  List<Object> get props => [fileName, filePath];

  const ReportGeneratedState(this.fileName, this.filePath);
}

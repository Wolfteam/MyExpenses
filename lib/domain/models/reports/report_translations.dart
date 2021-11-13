import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_translations.freezed.dart';

typedef PageXOfY = String Function(int x, int y);

typedef GeneratedOn = String Function(String on);

typedef AppVersion = String Function(String version);

typedef ReportWasSuccessfullyGenerated = String Function(String filename);

@freezed
class ReportTranslations with _$ReportTranslations {
  const factory ReportTranslations({
    required String appName,
    required String transactions,
    required String incomes,
    required String income,
    required String expenses,
    required String expense,
    required String total,
    required String transactionsReport,
    required String noTransactionsForThisPeriod,
    required String period,
    required String id,
    required String description,
    required String amount,
    required String date,
    required String category,
    required String type,
    required String recurring,
    required String yes,
    required String no,
    required String tapToOpen,
    required PageXOfY pageXOfY,
    required GeneratedOn generatedOn,
    required AppVersion appVersion,
    required ReportWasSuccessfullyGenerated reportWasSuccessfullyGenerated,
  }) = _ReportTranslations;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'background_translations.freezed.dart';
part 'background_translations.g.dart';

@freezed
sealed class BackgroundTranslations with _$BackgroundTranslations {
  const factory BackgroundTranslations({
    required String automaticSync,
    required String unknownErrorOccurred,
    required String syncWasSuccessfullyPerformed,
    required String recurringTransactions,
  }) = _BackgroundTranslations;

  factory BackgroundTranslations.fromJson(Map<String, dynamic> json) => _$BackgroundTranslationsFromJson(json);
}

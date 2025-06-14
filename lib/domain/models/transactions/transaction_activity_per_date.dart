import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_activity_per_date.freezed.dart';

@freezed
sealed class TransactionActivityPerDate with _$TransactionActivityPerDate {
  const factory TransactionActivityPerDate({
    required double income,
    required double expense,
    required double balance,
    String? dateRangeString,
  }) = _TransactionActivityPerDate;
}

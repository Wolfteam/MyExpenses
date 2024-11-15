import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'transactions_activity_per_date.freezed.dart';

@freezed
class TransactionActivityPerDate with _$TransactionActivityPerDate {
  const factory TransactionActivityPerDate({
    required double income,
    required double expense,
    required double balance,
    String? dateRangeString,
  }) = _TransactionActivityPerDate;
}

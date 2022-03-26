import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

import 'category_item.dart';

part 'transaction_item.freezed.dart';
part 'transaction_item.g.dart';

@freezed
class TransactionItem with _$TransactionItem {
  bool get isChildTransaction => parentTransactionId != null;

  const factory TransactionItem({
    required int id,
    required double amount,
    required String description,
    required DateTime transactionDate,
    required RepetitionCycleType repetitionCycle,
    int? parentTransactionId,
    required bool isParentTransaction,
    DateTime? nextRecurringDate,
    String? imagePath,
    required CategoryItem category,
    String? longDescription,
  }) = _TransactionItem;

  const TransactionItem._();

  factory TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);
}

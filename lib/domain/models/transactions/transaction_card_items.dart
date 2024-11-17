import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/models/transactions/transaction_item.dart';

part 'transaction_card_items.freezed.dart';

@freezed
class TransactionCardItems with _$TransactionCardItems {
  const factory TransactionCardItems({
    required String groupedBy,
    required double income,
    required double expense,
    required double balance,
    required List<TransactionItem> transactions,
  }) = _TransactionCardItems;
}

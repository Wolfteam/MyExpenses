import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_expenses/domain/enums/enums.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
sealed class Transaction with _$Transaction {
  const factory Transaction({
    required double amount,
    required String description,
    required DateTime transactionDate,
    required RepetitionCycleType repetitionCycle,
    String? parentTransactionCreatedHash,
    required bool isParentTransaction,
    DateTime? nextRecurringDate,
    String? imagePath,
    required String categoryCreatedHash,
    required DateTime createdAt,
    required String createdBy,
    required String createdHash,
    DateTime? updatedAt,
    String? updatedBy,
    String? longDescription,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

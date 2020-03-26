import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../common/enums/repetition_cycle_type.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final double amount;
  final String description;
  final DateTime transactionDate;
  final RepetitionCycleType repetitionCycle;
  final String parentTransactionCreatedHash;
  final bool isParentTransaction;
  final DateTime nextRecurringDate;
  final String imagePath;
  final String categoryCreatedHash;
  final DateTime createdAt;
  final String createdBy;
  final String createdHash;
  final DateTime updatedAt;
  final String updatedBy;

  const Transaction({
    @required this.amount,
    @required this.description,
    @required this.transactionDate,
    @required this.repetitionCycle,
    @required this.parentTransactionCreatedHash,
    @required this.isParentTransaction,
    @required this.nextRecurringDate,
    @required this.imagePath,
    @required this.categoryCreatedHash,
    @required this.createdAt,
    @required this.createdBy,
    @required this.createdHash,
    @required this.updatedAt,
    @required this.updatedBy,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

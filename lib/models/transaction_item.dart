import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

import '../common/enums/repetition_cycle_type.dart';
import 'category_item.dart';

part 'transaction_item.g.dart';

@JsonSerializable()
class TransactionItem extends Equatable {
  final int id;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final RepetitionCycleType repetitionCycle;
  final int parentTransactionId;
  final bool isParentTransaction;
  final DateTime nextRecurringDate;
  final String imagePath;
  final CategoryItem category;

  bool get isChildTransaction => parentTransactionId != null;

  @override
  List<Object> get props => [
        id,
        amount,
        description,
        transactionDate,
        repetitionCycle,
        parentTransactionId,
        isParentTransaction,
        nextRecurringDate,
        imagePath,
        category,
      ];

  const TransactionItem({
    @required this.id,
    @required this.amount,
    @required this.description,
    @required this.transactionDate,
    @required this.repetitionCycle,
    @required this.parentTransactionId,
    @required this.isParentTransaction,
    @required this.nextRecurringDate,
    @required this.imagePath,
    @required this.category,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);
}

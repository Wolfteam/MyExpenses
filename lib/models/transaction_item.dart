import 'package:json_annotation/json_annotation.dart';

import '../common/enums/repetition_cycle_type.dart';
import 'category_item.dart';

part 'transaction_item.g.dart';

@JsonSerializable()
class TransactionItem {
  int id;
  double amount;
  String description;
  DateTime transactionDate;
  int repetitions;
  RepetitionCycleType repetitionCycleType;
  CategoryItem category;

  TransactionItem({
    this.id,
    this.amount,
    this.description,
    this.transactionDate,
    this.repetitions,
    this.repetitionCycleType,
    this.category,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);
}

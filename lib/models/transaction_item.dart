import '../common/enums/repetition_cycle_type.dart';

import 'category_item.dart';

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
}

import 'category_item.dart';

class TransactionItem {
  double amount;
  String description;
  DateTime transactionDate;
  int repetitions;
  CategoryItem category;

  TransactionItem({
    this.amount,
    this.description,
    this.transactionDate,
    this.repetitions,
    this.category,
  });
}

import 'package:my_expenses/models/base_transaction.dart';

class TransactionsSummaryPerDay extends BaseTransaction {
  TransactionsSummaryPerDay(
    DateTime date,
    int amount,
  ) : super.withDate(amount: amount, createdAt: date);
}

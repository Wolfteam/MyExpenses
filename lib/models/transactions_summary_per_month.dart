import 'package:my_expenses/models/base_transaction.dart';

class TransactionsSummaryPerMonth extends BaseTransaction {
  int order;

  TransactionsSummaryPerMonth(
    this.order,
    int amount,
  ) : super(amount: amount);
}

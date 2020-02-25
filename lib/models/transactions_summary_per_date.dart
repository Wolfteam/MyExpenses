import '../models/base_transaction.dart';

class TransactionsSummaryPerDate extends BaseTransaction {
  final DateTime from;
  final DateTime to;
  final String dateRangeString;

  TransactionsSummaryPerDate(
    int amount,
    this.from,
    this.to,
    this.dateRangeString,
  ) : super(amount: amount);
}

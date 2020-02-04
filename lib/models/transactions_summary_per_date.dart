import '../common/utils/date_utils.dart';
import '../models/base_transaction.dart';

class TransactionsSummaryPerDate extends BaseTransaction {
  DateTime from;
  DateTime to;
  String get dateRange {
    var start = DateUtils.formatDate(from);
    var end = DateUtils.formatDate(to);

    return "$start - $end";
  }

  TransactionsSummaryPerDate(
    int amount,
    this.from,
    this.to,
  ) : super(amount: amount);
}

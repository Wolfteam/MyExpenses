import '../common/utils/date_utils.dart';
import '../models/base_transaction.dart';

class TransactionsSummaryPerDate extends BaseTransaction {
  DateTime from;
  DateTime to;
  String get dateRange {
    final start = DateUtils.formatDateWithoutLocale(from, DateUtils.monthAndDayFormat);
    final end = DateUtils.formatDateWithoutLocale(to, DateUtils.monthAndDayFormat);

    return '$start - $end';
  }

  TransactionsSummaryPerDate(
    int amount,
    this.from,
    this.to,
  ) : super(amount: amount);
}

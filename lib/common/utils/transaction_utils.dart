import 'dart:math';

import '../../models/transaction_item.dart';
import '../enums/repetition_cycle_type.dart';
import 'date_utils.dart';

class TransactionUtils {
  static double getTotalTransactionAmounts(
    List<TransactionItem> transactions, {
    bool onlyIncomes,
  }) {
    return transactions
        .where((t) => t.category.isAnIncome == onlyIncomes)
        .map((t) => t.amount)
        .fold(0, (t1, t2) => roundDouble(t1 + t2));
  }

  static double getTotalTransactionAmount(List<TransactionItem> transactions) =>
      transactions
          .map((t) => t.amount)
          .fold(0, (t1, t2) => roundDouble(t1 + t2));

  static DateTime getNextRecurringDate(
    RepetitionCycleType cycle,
    DateTime nextRecurringDate,
  ) {
    final daysToAdd = getRepetitionCycleInDays(cycle);
    switch (cycle) {
      case RepetitionCycleType.eachDay:
      case RepetitionCycleType.eachWeek:
        return nextRecurringDate.add(Duration(days: daysToAdd));
      case RepetitionCycleType.biweekly:
        return DateUtils.getNextBiweeklyDate(nextRecurringDate);
      case RepetitionCycleType.eachMonth:
        return DateUtils.getNextMonthDate(nextRecurringDate);
      default:
        throw Exception('Invalid repetition cycle');
    }
  }

  static int getRepetitionCycleInDays(
    RepetitionCycleType cycle,
  ) {
    switch (cycle) {
      case RepetitionCycleType.eachDay:
        return 1;
      case RepetitionCycleType.eachWeek:
        return 7;
      case RepetitionCycleType.eachMonth:
        return 30;
      case RepetitionCycleType.eachYear:
        return 365;
      default:
        return 0;
    }
  }

  static double roundDouble(double value, {int places = 2}) {
    final mod = pow(10.0, places);
    return (value * mod).round().toDouble() / mod;
  }
}

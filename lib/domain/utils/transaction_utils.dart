import 'dart:math';

import 'package:intl/intl.dart';
import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:tuple/tuple.dart';

class TransactionUtils {
  static double getTotalTransactionAmounts(List<TransactionItem> transactions, {bool onlyIncomes = false}) {
    return transactions.where((t) => t.category.isAnIncome == onlyIncomes).map((t) => t.amount).fold(0, (t1, t2) => roundDouble(t1 + t2));
  }

  static double getTotalTransactionAmount(List<TransactionItem> transactions) =>
      transactions.map((t) => t.amount).fold(0, (t1, t2) => roundDouble(t1 + t2));

  static DateTime getNextRecurringDate(RepetitionCycleType cycle, DateTime nextRecurringDate) {
    final daysToAdd = getRepetitionCycleInDays(cycle);
    switch (cycle) {
      case RepetitionCycleType.eachDay:
      case RepetitionCycleType.eachWeek:
      case RepetitionCycleType.eachYear:
        return nextRecurringDate.add(Duration(days: daysToAdd));
      case RepetitionCycleType.biweekly:
        return DateUtils.getNextBiweeklyDate(nextRecurringDate);
      case RepetitionCycleType.eachMonth:
        return DateUtils.getNextMonthDate(nextRecurringDate);
      default:
        throw Exception('Invalid repetition cycle');
    }
  }

  static int getRepetitionCycleInDays(RepetitionCycleType cycle) {
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

  static Tuple2<DateTime, List<DateTime>> getRecurringTransactionPeriods(
    RepetitionCycleType cycle,
    DateTime transactionDate,
    DateTime nextRecurringDate,
    DateTime untilDate,
  ) {
    bool allCompleted = false;
    var currentRecurringDate = nextRecurringDate;
    final periods = <DateTime>[];
    while (!allCompleted) {
      if (currentRecurringDate.isAfter(untilDate)) {
        allCompleted = true;
        break;
      }
      periods.add(currentRecurringDate);

      currentRecurringDate = getNextRecurringDate(cycle, currentRecurringDate);
    }

    if (cycle == RepetitionCycleType.eachMonth &&
        currentRecurringDate.day != transactionDate.day &&
        DateUtils.getLastDayDateOfTheMonth(currentRecurringDate).day == transactionDate.day) {
      currentRecurringDate = DateTime(currentRecurringDate.year, currentRecurringDate.month, transactionDate.day);
    }

    return Tuple2<DateTime, List<DateTime>>(currentRecurringDate, periods);
  }

  static List<TransactionCardItems> buildTransactionsPerMonth(
    LanguageModel language,
    List<TransactionItem> transactions, {
    SortDirectionType sortType = SortDirectionType.desc,
    bool sortByNextRecurringDate = false,
  }) {
    final transPerMonth = <DateTime, List<TransactionItem>>{};

    for (final transaction in transactions) {
      final dateToUse = (sortByNextRecurringDate ? transaction.nextRecurringDate : transaction.transactionDate)!;
      final date = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

      if (transPerMonth.keys.any((key) => key == date)) {
        transPerMonth[date]!.add(transaction);
      } else {
        transPerMonth.addAll({
          date: [transaction]
        });
      }
    }

    final models = <TransactionCardItems>[];

    for (final kvp in transPerMonth.entries) {
      final dateString = DateUtils.formatAppDate(kvp.key, language);
      final dayString = DateUtils.formatAppDate(kvp.key, language, DateUtils.dayStringFormat);

      final dateSummary = '$dateString ${toBeginningOfSentenceCase(dayString, language.code)}';

      models.add(TransactionCardItems(date: kvp.key, dateString: dateSummary, transactions: kvp.value));
    }

    if (sortType == SortDirectionType.asc) {
      models.sort((t1, t2) => t1.date.compareTo(t2.date));
    } else {
      models.sort((t1, t2) => t2.date.compareTo(t1.date));
    }

    return models;
  }
}

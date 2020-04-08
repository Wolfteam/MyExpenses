import 'dart:math';

import '../../daos/transactions_dao.dart';
import '../../models/transaction_item.dart';
import '../../services/logging_service.dart';
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

  static Future<List<TransactionItem>> checkRecurringTransactions(
    DateTime now,
    LoggingService logger,
    TransactionsDao _transactionsDao,
  ) async {
    final createdChilds = <TransactionItem>[];
    try {
      logger.info(
        TransactionUtils,
        'checkRecurringTransactions: Getting all parent transactions...',
      );
      final until = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final parents =
          await _transactionsDao.getAllParentTransactionsUntil(until);

      if (parents.isEmpty) {
        logger.info(
          TransactionUtils,
          'checkRecurringTransactions: There are no parent transactions...',
        );
        return createdChilds;
      }

      for (final parent in parents) {
        if (parent.repetitionCycle == RepetitionCycleType.none) {
          logger.warning(
            TransactionUtils,
            'checkRecurringTransactions: Transaction = ${parent.description} is marked as parent , ' +
                'but the repetition cycle is none...',
          );
          continue;
        }

        logger.info(
          TransactionUtils,
          'checkRecurringTransactions: Transaction initial date is = ${parent.transactionDate}\n' +
              'and next recurring date is = ${parent.nextRecurringDate}',
        );

        bool allCompleted = false;
        var currentRecurringDate = parent.nextRecurringDate;
        final periods = <DateTime>[];
        while (!allCompleted) {
          if (currentRecurringDate.isAfter(now)) {
            allCompleted = true;
            break;
          }
          periods.add(currentRecurringDate);

          currentRecurringDate = getNextRecurringDate(
            parent.repetitionCycle,
            currentRecurringDate,
          );
        }

        logger.info(
          TransactionUtils,
          'checkRecurringTransactions: Saving ${periods.length} periods for parent transaction id = ${parent.id}',
        );

        final childs = await _transactionsDao.checkAndSaveRecurringTransactions(
          parent,
          currentRecurringDate,
          periods,
        );

        createdChilds.addAll(childs);
      }
    } catch (e, s) {
      logger.error(
        TransactionUtils,
        'checkRecurringTransactions: Unknown error occurred',
        e,
        s,
      );
    }

    return createdChilds;
  }
}

import 'package:my_expenses/domain/enums/enums.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/generated/l10n.dart';

extension I18nExtensions on S {
  String translateAppThemeType(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.dark:
        return dark;
      case AppThemeType.light:
        return light;
      default:
        throw Exception('The provided app theme = $theme is not valid');
    }
  }

  String translateAppLanguageType(AppLanguageType lang) {
    switch (lang) {
      case AppLanguageType.english:
        return english;
      case AppLanguageType.spanish:
        return spanish;
      default:
        throw Exception('The provided app lang = $lang is not valid');
    }
  }

  String translateRepetitionCycleType(RepetitionCycleType cycle) {
    switch (cycle) {
      case RepetitionCycleType.none:
        return none;
      case RepetitionCycleType.eachDay:
        return eachDay;
      case RepetitionCycleType.eachWeek:
        return eachWeek;
      case RepetitionCycleType.eachMonth:
        return eachMonth;
      case RepetitionCycleType.biweekly:
        return biweekly;
      case RepetitionCycleType.eachYear:
        return eachYear;
      default:
        throw Exception('The provided repetition cycle = $cycle is not valid');
    }
  }

  String translateTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.incomes:
        return incomes;
      case TransactionType.expenses:
        return expenses;
      default:
        throw Exception('The provided transaction type = $type is not valid');
    }
  }

  String translateSyncIntervalType(SyncIntervalType interval) {
    switch (interval) {
      case SyncIntervalType.none:
        return none;
      case SyncIntervalType.eachHour:
        return eachHour;
      case SyncIntervalType.each3Hours:
        return each3Hours;
      case SyncIntervalType.each6Hours:
        return each6Hours;
      case SyncIntervalType.each12Hours:
        return each12Hours;
      case SyncIntervalType.eachDay:
        return eachDay;
      default:
        throw Exception('The provided sync interval = $interval is not valid');
    }
  }

  String getCategoryIconTypeName(CategoryIconType type) {
    switch (type) {
      case CategoryIconType.education:
        return education;
      case CategoryIconType.electronics:
        return electronics;
      case CategoryIconType.family:
        return family;
      case CategoryIconType.food:
        return food;
      case CategoryIconType.furniture:
        return furniture;
      case CategoryIconType.income:
        return income;
      case CategoryIconType.life:
        return life;
      case CategoryIconType.personal:
        return personal;
      case CategoryIconType.shopping:
        return shopping;
      case CategoryIconType.transportation:
        return transportation;
      case CategoryIconType.others:
        return others;
      case CategoryIconType.brands:
        return brands;
      case CategoryIconType.sports:
        return sports;
      case CategoryIconType.religion:
        return religion;
      case CategoryIconType.pets:
        return pets;
      default:
        return na;
    }
  }

  String getTransactionFilterTypeName(TransactionFilterType filter) {
    switch (filter) {
      case TransactionFilterType.description:
        return description;
      case TransactionFilterType.amount:
        return amount;
      case TransactionFilterType.date:
        return date;
      case TransactionFilterType.category:
        return category;
      default:
        throw Exception('Invalid transaction filter');
    }
  }

  String getSortDirectionName(SortDirectionType direction) {
    switch (direction) {
      case SortDirectionType.asc:
        return ascending;
      case SortDirectionType.desc:
        return descending;
      default:
        throw Exception('Invalid sort direction');
    }
  }

  String getReportFileTypeName(ReportFileType fileType) {
    switch (fileType) {
      case ReportFileType.csv:
        return csv;
      case ReportFileType.pdf:
        return pdf;
      default:
        throw Exception('Invalid file type');
    }
  }

  String getComparerTypeName(ComparerType comparerType) {
    switch (comparerType) {
      case ComparerType.equal:
        return equal;
      case ComparerType.greaterOrEqualThan:
        return greaterOrEqual;
      case ComparerType.lessOrEqualThan:
        return lessOrEqual;
      default:
        throw Exception('Invalid comparer type');
    }
  }

  BackgroundTranslations getBackgroundTranslations() {
    return BackgroundTranslations(
      automaticSync: automaticSync,
      recurringTransactions: recurringTransactions,
      syncWasSuccessfullyPerformed: syncWasSuccessfullyPerformed,
      unknownErrorOccurred: unknownErrorOcurred,
    );
  }

  ReportTranslations getReportTranslations() {
    return ReportTranslations(
      id: id,
      type: type,
      amount: amount,
      appName: appName,
      appVersion: appVersion,
      category: category,
      description: description,
      date: date,
      expenses: expenses,
      generatedOn: generatedOn,
      incomes: incomes,
      no: no,
      noTransactionsForThisPeriod: noTransactionsForThisPeriod,
      pageXOfY: pageXOfY,
      period: period,
      recurring: recurring,
      reportWasSuccessfullyGenerated: reportWasSuccessfullyGenerated,
      total: total,
      transactions: transactions,
      transactionsReport: transactionsReport,
      yes: yes,
      expense: expense,
      income: income,
      tapToOpen: tapToOpen,
    );
  }
}

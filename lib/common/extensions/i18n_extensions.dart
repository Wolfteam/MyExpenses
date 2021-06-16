import 'package:my_expenses/generated/l10n.dart';

import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/category_icon_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/enums/report_file_type.dart';
import '../../common/enums/sort_direction_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/enums/transaction_type.dart';
import '../enums/comparer_type.dart';
import '../enums/transaction_filter_type.dart';

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
}

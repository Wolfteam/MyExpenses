import '../../common/enums/app_language_type.dart';
import '../../common/enums/app_theme_type.dart';
import '../../common/enums/repetition_cycle_type.dart';
import '../../common/enums/sync_intervals_type.dart';
import '../../common/enums/transaction_type.dart';
import '../../generated/i18n.dart';

extension I18nExtensions on I18n {
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
        return repetitionCycleEachWeek;
      case RepetitionCycleType.eachMonth:
        return repetitionCycleEachMonth;
      case RepetitionCycleType.eachYear:
        return repetitionCycleEachYear;
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
        return syncIntervalEachHour;
      case SyncIntervalType.each3Hours:
        return syncIntervalEach3Hours;
      case SyncIntervalType.each6Hours:
        return syncIntervalEach6Hours;
      case SyncIntervalType.each12Hours:
        return syncIntervalEach12Hours;
      case SyncIntervalType.eachDay:
        return eachDay;
      default:
        throw Exception('The provided sync interval = $interval is not valid');
    }
  }
}

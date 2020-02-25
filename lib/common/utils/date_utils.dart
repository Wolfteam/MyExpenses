import 'package:intl/intl.dart';

import '../enums/app_language_type.dart';
import 'i18n_utils.dart';

class DateUtils {
  static const String fullMonthFormat = 'MMMM';
  static const String dayAndMonthFormat = 'dd/MM';
  static const String monthAndDayFormat = 'MM/dd';
  static const String dayStringFormat = 'EEEE';
  static const String monthDayAndYearFormat = 'dd/MM/yyyy';
  static const String fullMonthAndYearFormat = 'MMMM yyyy';

  static String formatAppDate(
    DateTime date,
    AppLanguageType language, [
    String format = dayAndMonthFormat,
  ]) {
    return formatDate(date, currentLocaleString(language), format);
  }

  static String formatDate(
    DateTime date,
    String locale, [
    String format = dayAndMonthFormat,
  ]) {
    final formatter = DateFormat(format, locale);
    final formatted = formatter.format(date);
    return formatted;
  }

  static String formatDateWithoutLocale(
    DateTime date, [
    String format = dayAndMonthFormat,
  ]) {
    final formatter = DateFormat(format);
    final formatted = formatter.format(date);
    return formatted;
  }

  static DateTime getFirstDayDateOfTheMonth(DateTime from) =>
      DateTime(from.year, from.month, 1);

  static DateTime getLastDayDateOfTheMonth(DateTime from) => (from.month < 12)
      ? DateTime(from.year, from.month + 1, 0, 23, 59, 59)
      : DateTime(from.year + 1, 1, 0, 23, 59, 59);
}

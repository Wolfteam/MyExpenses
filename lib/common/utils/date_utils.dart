import 'package:intl/intl.dart';

import '../enums/app_language_type.dart';
import 'i18n_utils.dart';

class DateUtils {
  static const String monthFormat = 'MMMM';
  static const String dayAndMonthFormat = 'dd/MM';
  static const String monthAndDayFormat = 'MM/dd';
  static const String dayStringFormat = 'EEEE';
  static const String monthDayAndYear = 'MM/dd/yyyy';

  static String formatAppDate(
    DateTime date,
    AppLanguageType language, [
    String format = dayAndMonthFormat,
  ]) {
    return formatDate(date, currentLocale(language), format);
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
}

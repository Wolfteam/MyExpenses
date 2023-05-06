import 'package:intl/intl.dart';
import 'package:my_expenses/domain/models/models.dart';
import 'package:tuple/tuple.dart';

class DateUtils {
  static const String fullMonthFormat = 'MMMM';
  static const String dayAndMonthFormat = 'dd/MM';
  static const String monthAndDayFormat = 'MM/dd';
  static const String dayStringFormat = 'EEEE';
  static const String monthDayAndYearFormat = 'dd/MM/yyyy';
  static const String fullMonthAndYearFormat = 'MMMM yyyy';
  static const String monthDayYearAndHourFormat = 'dd/MM/yyyy hh:mm:ss a';

  static String formatAppDate(DateTime? date, LanguageModel language, [String format = dayAndMonthFormat]) => formatDate(date, language.code, format);

  static String formatDate(DateTime? date, String languageCode, [String format = dayAndMonthFormat]) {
    if (date == null) {
      return '';
    }
    final formatter = DateFormat(format, languageCode);
    final formatted = formatter.format(date);
    return formatted;
  }

  static String formatDateWithoutLocale(DateTime? date, [String format = dayAndMonthFormat]) {
    if (date == null) {
      return '';
    }
    final formatter = DateFormat(format);
    final formatted = formatter.format(date);
    return formatted;
  }

  static DateTime getFirstDayDateOfTheMonth(DateTime from) => DateTime(from.year, from.month);

  static DateTime getLastDayDateOfTheMonth(DateTime from) =>
      (from.month < 12) ? DateTime(from.year, from.month + 1, 0, 23, 59, 59) : DateTime(from.year + 1, 1, 0, 23, 59, 59);

  static DateTime getNextMonthDate(DateTime from) {
    DateTime tentativeDate = DateTime(from.year, from.month + 1, from.day);
    final monthsDiff = tentativeDate.month - from.month;
    if (tentativeDate.day == from.day) {
      return tentativeDate;
    }

    //If monthsDiff > 1 that means that we are in february
    if (monthsDiff > 1) {
      tentativeDate = DateTime(from.year, from.month + 1);
    }

    final daysInNextMonth = getLastDayDateOfTheMonth(tentativeDate).day;
    if (from.day > daysInNextMonth) {
      return DateTime(
        tentativeDate.year,
        tentativeDate.month,
        daysInNextMonth,
      );
    }
    return DateTime(
      tentativeDate.year,
      tentativeDate.month,
      from.day,
    );
  }

  static DateTime getNextBiweeklyDate(DateTime from) {
    const fifteen = 15;
    final lastDateOfTheMonth = getLastDayDateOfTheMonth(from);

    if (from.day == fifteen) {
      return from.subtract(const Duration(days: fifteen)).add(Duration(days: lastDateOfTheMonth.day));
    } else if (from.day < fifteen) {
      return DateTime(from.year, from.month, fifteen);
    } else {
      if (from.day == lastDateOfTheMonth.day) {
        return from.add(const Duration(days: fifteen));
      } else {
        return lastDateOfTheMonth;
      }
    }
  }

  static Tuple2<DateTime?, DateTime?> correctDates(DateTime? from, DateTime? to, {bool fromHasPriority = true}) {
    var start = from;
    var until = to;

    if (from == null || to == null) {
      return Tuple2(start, until);
    }

    if (fromHasPriority) {
      if (from.isAfter(to)) {
        until = from;
      }
    } else {
      if (to.isBefore(from)) {
        start = to.add(const Duration(days: -1));
      }
    }
    return Tuple2(start, until);
  }
}

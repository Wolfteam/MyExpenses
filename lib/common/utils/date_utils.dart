import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date, {String format = "dd/MM"}) {
    var formatter = new DateFormat(format);
    var formatted = formatter.format(date);
    return formatted;
  }
}

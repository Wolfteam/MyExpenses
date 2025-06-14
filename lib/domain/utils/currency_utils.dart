import 'package:intl/intl.dart';
import 'package:my_expenses/domain/enums/enums.dart';

class CurrencyUtils {
  static String getCurrencySymbol(CurrencySymbolType type) {
    switch (type) {
      case CurrencySymbolType.dolar:
        return '\$';
      case CurrencySymbolType.brazilianReal:
        return 'R\$';
      case CurrencySymbolType.yen:
        return '¥';
      case CurrencySymbolType.euro:
        return '€';
      case CurrencySymbolType.pounds:
        return '£';
    }
  }

  static String formatNumber(
    double amount, {
    int decimalDigits = 2,
    String symbol = '\$',
    String symbolSeparator = ' ',
    bool symbolToTheRight = true,
    String thousandSeparator = ',',
    String decimalSeparator = '.',
  }) {
    final baseFormat = _refineSeparator(amount, decimalDigits, thousandSeparator, decimalSeparator);
    if (!symbolToTheRight) return '$symbol$symbolSeparator$baseFormat';

    return '$baseFormat$symbolSeparator$symbol';
  }

  static String _baseFormat(double amount, int decimalDigits) =>
      NumberFormat.currency(symbol: '', decimalDigits: decimalDigits, locale: 'en_US').format(amount);

  static String _refineSeparator(double amount, int decimalDigits, String thousandSeparator, String decimalSeparator) =>
      _baseFormat(
        amount,
        decimalDigits,
      ).replaceAll(',', '(,)').replaceAll('.', '(.)').replaceAll('(,)', thousandSeparator).replaceAll('(.)', decimalSeparator);
}

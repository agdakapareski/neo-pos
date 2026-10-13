import 'package:intl/intl.dart';

class CurrencyHelper {
  /// Format double as currency (IDR by default)
  static String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: '$symbol ');
    return formatter.format(amount);
  }

  /// Format double as number with 2 decimals
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Parse string to double
  static double? parseDouble(String value) {
    try {
      return double.parse(value.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol
  static String getCurrencySymbol({String locale = 'id_ID'}) {
    return NumberFormat.compactSimpleCurrency(locale: locale).currencySymbol;
  }

  /// Format for receipt display
  static String formatForReceipt(double amount) {
    return 'Rp ${NumberFormat('#,##0', 'id_ID').format(amount)}';
  }
}

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _priceFormat = NumberFormat.currency(
    locale: AppConstants.locale,
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final NumberFormat _qtyFormat = NumberFormat.decimalPattern(
    AppConstants.locale,
  )..maximumFractionDigits = 4;

  static final NumberFormat _percentFormat =
      NumberFormat.decimalPercentPattern()..maximumFractionDigits = 2;

  static String price(Decimal value) => _priceFormat.format(value.toDouble());

  static String quantity(Decimal value) => _qtyFormat.format(value.toDouble());

  static String percent(Decimal value) =>
      _percentFormat.format(value.toDouble());

  static String signed(Decimal value) {
    final formatted = _priceFormat.format(value.abs().toDouble());
    if (value > Decimal.zero) return '+$formatted';
    if (value < Decimal.zero) return '-$formatted';
    return formatted;
  }

  static String signedPercent(Decimal value) {
    final pct = value.toDouble() * 100;
    final formatted = '${pct.abs().toStringAsFixed(2)}%';
    if (pct > 0) return '+$formatted';
    if (pct < 0) return '-$formatted';
    return formatted;
  }
}

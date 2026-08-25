import 'package:decimal/decimal.dart';

class DecimalUtils {
  DecimalUtils._();

  static Decimal parse(String value) {
    final cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return Decimal.zero;
    return Decimal.parse(cleaned);
  }

  static Decimal tryParse(String value) {
    try {
      return parse(value);
    } catch (_) {
      return Decimal.zero;
    }
  }

  /// Safe decimal division — `Decimal / Decimal` returns a `Rational`,
  /// which throws if re-parsed via `.toString()` when the result doesn't
  /// terminate (e.g. 1/3). This rounds instead of throwing.
  static Decimal divide(Decimal a, Decimal b, {int scale = 6}) {
    if (b == Decimal.zero) return Decimal.zero;
    return (a / b).toDecimal(scaleOnInfinitePrecision: scale);
  }

  static Decimal fromDouble(double value) =>
      Decimal.parse(value.toStringAsFixed(6));

  static double toDouble(Decimal value) => value.toDouble();

  static bool isPositive(Decimal value) => value > Decimal.zero;
  static bool isNegative(Decimal value) => value < Decimal.zero;
  static bool isZero(Decimal value) => value == Decimal.zero;

  static Decimal min(Decimal a, Decimal b) => a < b ? a : b;
  static Decimal max(Decimal a, Decimal b) => a > b ? a : b;

  static Decimal abs(Decimal value) => value < Decimal.zero ? -value : value;
}

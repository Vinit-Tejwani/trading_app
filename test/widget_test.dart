import 'package:flutter_test/flutter_test.dart';

import 'package:trading_app/core/utils/decimal_utils.dart';

void main() {
  test('DecimalUtils.tryParse handles invalid input gracefully', () {
    expect(DecimalUtils.tryParse(''), isNotNull);
    expect(DecimalUtils.tryParse('abc').toDouble(), 0.0);
    expect(DecimalUtils.tryParse('12.34').toDouble(), 12.34);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/app_constants.dart';
import 'package:trading_app/features/market_data/data/mock_market_feed.dart';

void main() {
  test('mock feed snapshot returns all 10 stocks', () {
    final feed = MockMarketFeed.instance;
    feed.start();
    final snapshot = feed.snapshot();
    expect(snapshot.length, 10);
    expect(
      snapshot.map((q) => q.stock.symbol).toSet(),
      AppConstants.stockSeeds.map((s) => s.symbol).toSet(),
    );
  });

  test('snapshot price matches seed price on initial read', () {
    final feed = MockMarketFeed.instance;
    final quote = feed.quoteFor('RELIANCE');
    expect(quote, isNotNull);
    expect(quote!.tick.change.toDouble(), 0.0);
    expect(quote.tick.changePercent.toDouble(), 0.0);
  });

  test('quoteFor returns null for unknown symbol', () {
    final feed = MockMarketFeed.instance;
    expect(feed.quoteFor('NOTREAL'), isNull);
  });
}

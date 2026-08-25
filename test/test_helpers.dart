import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/core/storage/local_storage.dart';
import 'package:trading_app/features/holdings/domain/entities/holding.dart';
import 'package:trading_app/features/market_data/data/mock_market_feed.dart';
import 'package:trading_app/features/market_data/domain/entities/stock.dart';
import 'package:trading_app/features/watchlist/domain/entities/watchlist.dart';
import 'package:trading_app/l10n/app_localizations_en.dart';

Future<LocalStorage> createStorage([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return LocalStorage(await SharedPreferences.getInstance());
}

AppLocalizationsEn english() => AppLocalizationsEn();

MockMarketFeed createFeed() => MockMarketFeed.forTesting();

Watchlist watchlist({
  String id = 'watchlist-1',
  String name = 'Primary',
  List<String> symbols = const ['RELIANCE', 'TCS', 'INFY'],
}) {
  return Watchlist(
    id: id,
    name: name,
    symbols: symbols,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

Holding holding({
  String symbol = 'RELIANCE',
  String quantity = '2',
  String avgCost = '100',
}) {
  return Holding(
    symbol: symbol,
    quantity: Decimal.parse(quantity),
    avgCost: Decimal.parse(avgCost),
  );
}

Order order({
  String id = 'order-1',
  String symbol = 'RELIANCE',
  OrderSide side = OrderSide.buy,
  String quantity = '2',
  String price = '100',
  String value = '200',
}) {
  return Order(
    id: id,
    symbol: symbol,
    side: side,
    quantity: Decimal.parse(quantity),
    price: Decimal.parse(price),
    value: Decimal.parse(value),
    timestamp: DateTime.utc(2026, 1, 1),
  );
}

PriceTick tick({
  String symbol = 'RELIANCE',
  String price = '3000',
  String change = '10',
  String changePercent = '0.003',
  String previousPrice = '2990',
}) {
  return PriceTick(
    symbol: symbol,
    price: Decimal.parse(price),
    change: Decimal.parse(change),
    changePercent: Decimal.parse(changePercent),
    timestamp: DateTime.utc(2026, 1, 1),
    previousPrice: Decimal.parse(previousPrice),
  );
}

Quote quoteForTick(PriceTick priceTick) {
  return Quote(
    stock: Stock(symbol: priceTick.symbol, name: 'Reliance Industries'),
    tick: priceTick,
    openPrice: Decimal.parse('2990'),
  );
}

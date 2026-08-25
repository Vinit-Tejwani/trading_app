import 'package:decimal/decimal.dart';

class AppConstants {
  AppConstants._();

  static const String appName = '021 Trading';
  static const String currencySymbol = '₹';
  static const String locale = 'en_IN';

  static const int defaultTickRateMs = 1000;
  static const int stressTickRateMs = 200;
  static const int maxStressTickRateMs = 100;

  static final Decimal initialWalletBalance = Decimal.fromInt(1000000);

  static final List<StockSeed> stockSeeds = [
    StockSeed(
      symbol: 'RELIANCE',
      name: 'Reliance Industries',
      price: Decimal.parse('2945.50'),
    ),
    StockSeed(
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
      price: Decimal.parse('4120.75'),
    ),
    StockSeed(symbol: 'INFY', name: 'Infosys', price: Decimal.parse('1845.20')),
    StockSeed(
      symbol: 'HDFCBANK',
      name: 'HDFC Bank',
      price: Decimal.parse('1672.40'),
    ),
    StockSeed(
      symbol: 'ICICIBANK',
      name: 'ICICI Bank',
      price: Decimal.parse('1258.90'),
    ),
    StockSeed(
      symbol: 'SBIN',
      name: 'State Bank of India',
      price: Decimal.parse('824.15'),
    ),
    StockSeed(
      symbol: 'ITC',
      name: 'ITC Limited',
      price: Decimal.parse('478.60'),
    ),
    StockSeed(
      symbol: 'LT',
      name: 'Larsen & Toubro',
      price: Decimal.parse('3621.85'),
    ),
    StockSeed(
      symbol: 'BHARTIARTL',
      name: 'Bharti Airtel',
      price: Decimal.parse('1547.25'),
    ),
    StockSeed(
      symbol: 'AXISBANK',
      name: 'Axis Bank',
      price: Decimal.parse('1189.50'),
    ),
  ];

  static const String prefKeyWatchlists = 'watchlists_v1';
  static const String prefKeyHoldings = 'holdings_v1';
  static const String prefKeyOrders = 'orders_v1';
  static const String prefKeyWallet = 'wallet_v1';
  static const String prefKeyTickRate = 'tick_rate_v1';
  static const String prefKeyThemeMode = 'theme_mode_v1';
}

class StockSeed {
  final String symbol;
  final String name;
  final Decimal price;

  const StockSeed({
    required this.symbol,
    required this.name,
    required this.price,
  });
}

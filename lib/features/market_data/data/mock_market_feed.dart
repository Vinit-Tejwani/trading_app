import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/decimal_utils.dart';
import '../domain/entities/stock.dart';

/// Singleton mock market-data feed.
///
/// Emits PriceTick events for all 10 stocks at a configurable interval
/// (default 1 tick/sec/stock = 10 ticks/sec total; configurable up to ~50/sec).
///
/// Uses a random-walk algorithm with mean reversion for realistic price action.
/// All subscribers share one broadcast stream — single source of truth.
class MockMarketFeed {
  MockMarketFeed._();

  /// Creates an isolated feed for tests.
  MockMarketFeed.forTesting() : this._();

  static final MockMarketFeed instance = MockMarketFeed._();

  final StreamController<PriceTick> _controller =
      StreamController<PriceTick>.broadcast();

  Timer? _timer;
  int _tickRateMs = AppConstants.defaultTickRateMs;
  bool _disposed = false;

  final Map<String, _StockState> _state = {};
  final Map<String, Stock> _stocks = {};
  final Random _rng = Random(42);

  Stream<PriceTick> get ticks => _controller.stream;

  /// Emits a deterministic tick for unit tests.
  @visibleForTesting
  void emitForTesting(PriceTick tick) {
    if (!_controller.isClosed) _controller.add(tick);
  }

  int get tickRateMs => _tickRateMs;

  void setTickRate(int ms) {
    if (ms < 50) ms = 50;
    if (_tickRateMs == ms) return;
    _tickRateMs = ms;
    _restart();
  }

  void start() {
    if (_timer != null) return;
    _seed();
    _restart();
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: _tickRateMs),
      (_) => _emitTicks(),
    );
  }

  void _seed() {
    for (final seed in AppConstants.stockSeeds) {
      _stocks[seed.symbol] = Stock(symbol: seed.symbol, name: seed.name);
      _state[seed.symbol] = _StockState(
        price: seed.price,
        previousPrice: seed.price,
        openPrice: seed.price,
      );
    }
  }

  void _emitTicks() {
    if (_disposed || _controller.isClosed || _state.isEmpty) return;

    final now = DateTime.now();
    final symbols = _state.keys.toList();

    // Randomly decide how many stocks move in this tick.
    //
    // 50% -> 1 stock
    // 30% -> 2-3 stocks
    // 12% -> 4-5 stocks
    // 5%  -> 6-7 stocks
    // 3%  -> all stocks
    final roll = _rng.nextInt(100);

    final int count;

    if (roll < 50) {
      count = 1;
    } else if (roll < 80) {
      count = 2 + _rng.nextInt(2); // 2-3
    } else if (roll < 92) {
      count = 4 + _rng.nextInt(2); // 4-5
    } else if (roll < 97) {
      count = 6 + _rng.nextInt(2); // 6-7
    } else {
      count = symbols.length; // all 10
    }

    // Randomly select which stocks move.
    symbols.shuffle(_rng);

    for (final sym in symbols.take(count)) {
      final st = _state[sym]!;

      final newPrice = _nextPrice(st);

      final change = newPrice - st.openPrice;

      final changePercent = st.openPrice == Decimal.zero
          ? Decimal.zero
          : DecimalUtils.divide(
              change,
              st.openPrice,
              scale: 8,
            );

      final tick = PriceTick(
        symbol: sym,
        price: newPrice,
        change: change,
        changePercent: changePercent,
        timestamp: now,
        previousPrice: st.price,
      );

      st.previousPrice = st.price;
      st.price = newPrice;

      _controller.add(tick);
    }
  }

  /// Random walk with mean reversion — pulls price gently back toward open
  /// and adds gaussian-ish noise scaled per-volatility.
  Decimal _nextPrice(_StockState st) {
    final priceD = st.price.toDouble();
    final openD = st.openPrice.toDouble();
    final volatility = priceD * 0.002;
    final meanPull = openD == 0 ? 0.0 : ((openD - priceD) / openD) * 5.0;
    final noise = _rng.nextDouble() - 0.5 + meanPull;
    final delta = noise * volatility;
    final next = priceD + delta;
    final clamped = next.clamp(priceD * 0.7, priceD * 1.3);
    return Decimal.parse(clamped.toStringAsFixed(2));
  }

  /// Synchronous read of current state — used for initial UI snapshots.
  List<Quote> snapshot() {
    return _stocks.values.map((s) {
      final st = _state[s.symbol]!;
      final change = st.price - st.openPrice;
      final changePercent = st.openPrice == Decimal.zero
          ? Decimal.zero
          : DecimalUtils.divide(change, st.openPrice, scale: 8);
      final tick = PriceTick(
        symbol: s.symbol,
        price: st.price,
        change: change,
        changePercent: changePercent,
        timestamp: DateTime.now(),
        previousPrice: st.price,
      );
      return Quote(stock: s, tick: tick, openPrice: st.openPrice);
    }).toList();
  }

  Quote? quoteFor(String symbol) {
    final s = _stocks[symbol];
    final st = _state[symbol];
    if (s == null || st == null) return null;
    final change = st.price - st.openPrice;
    final changePercent = st.openPrice == Decimal.zero
        ? Decimal.zero
        : DecimalUtils.divide(change, st.openPrice, scale: 8);
    final tick = PriceTick(
      symbol: symbol,
      price: st.price,
      change: change,
      changePercent: changePercent,
      timestamp: DateTime.now(),
      previousPrice: st.price,
    );
    return Quote(stock: s, tick: tick, openPrice: st.openPrice);
  }

  List<Stock> allStocks() => _stocks.values.toList(growable: false);

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await _controller.close();
  }
}

class _StockState {
  Decimal price;
  Decimal previousPrice;
  Decimal openPrice;

  _StockState({
    required this.price,
    required this.previousPrice,
    required this.openPrice,
  });
}

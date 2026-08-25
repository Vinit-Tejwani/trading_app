import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/mock_market_feed.dart';
import '../../domain/entities/stock.dart';
import 'market_state.dart';

export 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc({MockMarketFeed? feed})
      : _feed = feed ?? MockMarketFeed.instance,
        super(MarketState.initial()) {
    on<MarketStarted>(_onStarted);
    on<MarketTickReceived>(_onTick);
    on<MarketTickRateChanged>(_onTickRate);
  }

  final MockMarketFeed _feed;
  StreamSubscription<PriceTick>? _sub;

  Future<void> _onStarted(
      MarketStarted event, Emitter<MarketState> emit) async {
    // Seed the feed before taking the first snapshot. The previous order
    // produced an empty market state because the singleton seeds lazily.
    _feed.start();
    final snapshot = _feed.snapshot();
    final bySymbol = {
      for (final q in snapshot) q.stock.symbol: q,
    };
    emit(state.copyWith(quotesBySymbol: bySymbol));
    await _sub?.cancel();
    _sub = _feed.ticks.listen(
      (tick) => add(MarketTickReceived(tick)),
    );
  }

  void _onTick(MarketTickReceived event, Emitter<MarketState> emit) {
    final existing = state.quotesBySymbol[event.tick.symbol];
    if (existing == null) return;
    final updated = existing.copyWith(tick: event.tick);
    final newMap = Map<String, Quote>.from(state.quotesBySymbol);
    newMap[event.tick.symbol] = updated;
    emit(state.copyWith(quotesBySymbol: newMap));
  }

  void _onTickRate(MarketTickRateChanged event, Emitter<MarketState> emit) {
    _feed.setTickRate(event.ms);
    emit(state.copyWith(tickRateMs: event.ms));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

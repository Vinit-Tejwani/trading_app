import 'package:equatable/equatable.dart';

import '../../domain/entities/stock.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object?> get props => [];
}

class MarketStarted extends MarketEvent {
  const MarketStarted();
}

class MarketTickReceived extends MarketEvent {
  final PriceTick tick;
  const MarketTickReceived(this.tick);
  @override
  List<Object?> get props => [tick];
}

class MarketTickRateChanged extends MarketEvent {
  final int ms;
  const MarketTickRateChanged(this.ms);
  @override
  List<Object?> get props => [ms];
}

class MarketState extends Equatable {
  final Map<String, Quote> quotesBySymbol;
  final int tickRateMs;

  const MarketState({required this.quotesBySymbol, required this.tickRateMs});

  factory MarketState.initial() =>
      const MarketState(quotesBySymbol: {}, tickRateMs: 1000);

  Quote? quote(String symbol) => quotesBySymbol[symbol];

  MarketState copyWith({
    Map<String, Quote>? quotesBySymbol,
    int? tickRateMs,
  }) {
    return MarketState(
      quotesBySymbol: quotesBySymbol ?? this.quotesBySymbol,
      tickRateMs: tickRateMs ?? this.tickRateMs,
    );
  }

  @override
  List<Object?> get props => [quotesBySymbol, tickRateMs];
}

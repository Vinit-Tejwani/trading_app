import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final String name;

  const Stock({required this.symbol, required this.name});

  @override
  List<Object?> get props => [symbol, name];
}

class PriceTick extends Equatable {
  final String symbol;
  final Decimal price;
  final Decimal change;
  final Decimal changePercent;
  final DateTime timestamp;
  final Decimal previousPrice;

  const PriceTick({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    required this.previousPrice,
  });

  bool get isUp => price > previousPrice;
  bool get isDown => price < previousPrice;
  bool get isFlat => price == previousPrice;

  PriceTick copyWith({
    Decimal? price,
    Decimal? change,
    Decimal? changePercent,
    DateTime? timestamp,
    Decimal? previousPrice,
  }) {
    return PriceTick(
      symbol: symbol,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      timestamp: timestamp ?? this.timestamp,
      previousPrice: previousPrice ?? this.previousPrice,
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        price,
        change,
        changePercent,
        timestamp,
        previousPrice,
      ];
}

class Quote extends Equatable {
  final Stock stock;
  final PriceTick tick;
  final Decimal openPrice;

  const Quote(
      {required this.stock, required this.tick, required this.openPrice});

  Quote copyWith({PriceTick? tick}) =>
      Quote(stock: stock, tick: tick ?? this.tick, openPrice: openPrice);

  @override
  List<Object?> get props => [stock, tick, openPrice];
}

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/core/utils/decimal_utils.dart';

class Order extends Equatable {
  final String id;
  final String symbol;
  final OrderSide side;
  final Decimal quantity;
  final Decimal price;
  final Decimal value;
  final DateTime timestamp;

  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.value,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'side': side.name,
        'quantity': quantity.toString(),
        'price': price.toString(),
        'value': value.toString(),
        'timestamp': timestamp.toIso8601String(),
      };

  static Order fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        symbol: j['symbol'] as String,
        side: OrderSide.values.byName(j['side'] as String),
        quantity: Decimal.parse(j['quantity'] as String),
        price: Decimal.parse(j['price'] as String),
        value: Decimal.parse(j['value'] as String),
        timestamp: DateTime.parse(j['timestamp'] as String),
      );

  @override
  List<Object?> get props =>
      [id, symbol, side, quantity, price, value, timestamp];
}

class Holding extends Equatable {
  final String symbol;
  final Decimal quantity;
  final Decimal avgCost;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCost,
  });

  Decimal get invested => quantity * avgCost;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity.toString(),
        'avgCost': avgCost.toString(),
      };

  static Holding fromJson(Map<String, dynamic> j) => Holding(
        symbol: j['symbol'] as String,
        quantity: Decimal.parse(j['quantity'] as String),
        avgCost: Decimal.parse(j['avgCost'] as String),
      );

  @override
  List<Object?> get props => [symbol, quantity, avgCost];
}

class HoldingsSummary extends Equatable {
  final Decimal totalInvested;
  final Decimal currentValue;
  final Decimal totalPnl;
  final Decimal totalPnlPercent;

  const HoldingsSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  });

  factory HoldingsSummary.fromRows(Iterable<HoldingRow> rows) {
    Decimal invested = Decimal.zero;
    Decimal current = Decimal.zero;
    for (final r in rows) {
      invested = invested + r.holding.invested;
      current = current + r.currentValue;
    }
    final pnl = current - invested;
    final pct = invested == Decimal.zero
        ? Decimal.zero
        : DecimalUtils.divide(pnl, invested, scale: 8);
    return HoldingsSummary(
      totalInvested: invested,
      currentValue: current,
      totalPnl: pnl,
      totalPnlPercent: pct,
    );
  }

  @override
  List<Object?> get props =>
      [totalInvested, currentValue, totalPnl, totalPnlPercent];
}

class HoldingRow extends Equatable {
  final Holding holding;
  final Decimal ltp;
  final Decimal previousLtp;

  const HoldingRow({
    required this.holding,
    required this.ltp,
    required this.previousLtp,
  });

  Decimal get currentValue => holding.quantity * ltp;
  Decimal get pnl => currentValue - holding.invested;
  Decimal get pnlPercent => holding.invested == Decimal.zero
      ? Decimal.zero
      : DecimalUtils.divide(pnl, holding.invested, scale: 8);

  HoldingRow copyWith({Decimal? ltp, Decimal? previousLtp}) {
    return HoldingRow(
      holding: holding,
      ltp: ltp ?? this.ltp,
      previousLtp: previousLtp ?? this.previousLtp,
    );
  }

  @override
  List<Object?> get props => [holding, ltp, previousLtp];
}

import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:trading_app/core/constants/enum.dart';

import '../../../holdings/domain/entities/holding.dart';

class OrderDraft extends Equatable {
  final String symbol;
  final OrderSide side;
  final Decimal quantity;
  final Decimal price;

  const OrderDraft({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
  });

  Decimal get value => quantity * price;

  OrderDraft copyWith({
    OrderSide? side,
    Decimal? quantity,
    Decimal? price,
  }) =>
      OrderDraft(
        symbol: symbol,
        side: side ?? this.side,
        quantity: quantity ?? this.quantity,
        price: price ?? this.price,
      );

  @override
  List<Object?> get props => [symbol, side, quantity, price];
}

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderInitialized extends OrderEvent {
  final String symbol;
  const OrderInitialized(this.symbol);
  @override
  List<Object?> get props => [symbol];
}

class OrderSideToggled extends OrderEvent {
  final OrderSide side;
  const OrderSideToggled(this.side);
  @override
  List<Object?> get props => [side];
}

class OrderQuantityChanged extends OrderEvent {
  final Decimal quantity;
  const OrderQuantityChanged(this.quantity);
  @override
  List<Object?> get props => [quantity];
}

class OrderPriceRefreshed extends OrderEvent {
  final Decimal price;
  const OrderPriceRefreshed(this.price);
  @override
  List<Object?> get props => [price];
}

class OrderSubmitted extends OrderEvent {
  const OrderSubmitted();
}

class OrderState extends Equatable {
  final OrderDraft? draft;
  final String? error;
  final Order? lastOrder;
  final bool submitting;

  const OrderState({
    this.draft,
    this.error,
    this.lastOrder,
    this.submitting = false,
  });

  factory OrderState.empty() => const OrderState();

  OrderState copyWith({
    OrderDraft? draft,
    String? error,
    bool clearError = false,
    Order? lastOrder,
    bool? submitting,
  }) {
    return OrderState(
      draft: draft ?? this.draft,
      error: clearError ? null : (error ?? this.error),
      lastOrder: lastOrder ?? this.lastOrder,
      submitting: submitting ?? this.submitting,
    );
  }

  @override
  List<Object?> get props => [draft, error, lastOrder, submitting];
}

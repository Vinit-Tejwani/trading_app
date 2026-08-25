import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/l10n/app_localizations.dart';

import '../../../holdings/data/portfolio_repository.dart';
import '../../../market_data/data/mock_market_feed.dart';
import 'order_state.dart';

export 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc(
    this._portfolio, {
    required AppLocalizations l10n,
    MockMarketFeed? feed,
  })  : _l10n = l10n,
        _feed = feed ?? MockMarketFeed.instance,
        super(OrderState.empty()) {
    on<OrderInitialized>(_onInit);
    on<OrderSideToggled>((e, emit) {
      final d = state.draft;
      if (d == null) return;
      emit(state.copyWith(draft: d.copyWith(side: e.side), clearError: true));
    });
    on<OrderQuantityChanged>((e, emit) {
      final d = state.draft;
      if (d == null) return;
      emit(state.copyWith(
        draft: d.copyWith(quantity: e.quantity),
        clearError: true,
      ));
    });
    on<OrderPriceRefreshed>((e, emit) {
      final d = state.draft;
      if (d == null) return;
      emit(state.copyWith(draft: d.copyWith(price: e.price)));
    });
    on<OrderSubmitted>(_onSubmit);
  }

  final PortfolioRepository _portfolio;
  final AppLocalizations _l10n;
  final MockMarketFeed _feed;

  void _onInit(OrderInitialized event, Emitter<OrderState> emit) {
    final q = _feed.quoteFor(event.symbol);
    if (q == null) {
      emit(state.copyWith(error: _l10n.unknownSymbol(event.symbol)));
      return;
    }
    emit(state.copyWith(
      draft: OrderDraft(
        symbol: event.symbol,
        side: OrderSide.buy,
        quantity: Decimal.one,
        price: q.tick.price,
      ),
      clearError: true,
    ));
  }

  Future<void> _onSubmit(
    OrderSubmitted event,
    Emitter<OrderState> emit,
  ) async {
    final d = state.draft;
    if (d == null) return;

    final qty = d.quantity;
    if (qty <= Decimal.zero) {
      emit(state.copyWith(error: _l10n.quantityMustBeGreaterThanZero));
      return;
    }
    // Allow up to 4 decimal places for fractional shares.
    final qtyStr = qty.toString();
    final dotIdx = qtyStr.indexOf('.');
    if (dotIdx >= 0 && qtyStr.length - dotIdx - 1 > 4) {
      emit(state.copyWith(error: _l10n.quantityMaxDecimals));
      return;
    }

    // Always execute against the feed's latest price, never the price that
    // happened to be rendered when the user opened the ticket.
    final liveQuote = _feed.quoteFor(d.symbol);
    if (liveQuote == null) {
      emit(state.copyWith(error: _l10n.livePriceUnavailable));
      return;
    }
    final executionPrice = liveQuote.tick.price;
    final value = qty * executionPrice;
    emit(state.copyWith(
        draft: d.copyWith(price: executionPrice), clearError: true));

    if (d.side == OrderSide.buy) {
      if (value > _portfolio.balance) {
        emit(state.copyWith(
          error: _l10n.insufficientBalance(
            _formatBalance(_portfolio.balance),
            _formatBalance(value),
          ),
        ));
        return;
      }
    } else {
      final existing =
          _portfolio.holdings.where((h) => h.symbol == d.symbol).toList();
      if (existing.isEmpty || existing.first.quantity < qty) {
        emit(state.copyWith(
          error: _l10n.insufficientQuantity(
            existing.isEmpty
                ? _l10n.zeroQuantity
                : _formatQty(existing.first.quantity),
            d.symbol,
          ),
        ));
        return;
      }
    }

    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final order = await _portfolio.placeOrder(
        symbol: d.symbol,
        side: d.side,
        quantity: qty,
        price: executionPrice,
      );
      emit(state.copyWith(submitting: false, lastOrder: order));
    } catch (e) {
      emit(state.copyWith(submitting: false, error: e.toString()));
    }
  }

  String _formatBalance(Decimal v) => '₹${v.toDouble().toStringAsFixed(2)}';
  String _formatQty(Decimal v) => v.toDouble().toStringAsFixed(4);
}

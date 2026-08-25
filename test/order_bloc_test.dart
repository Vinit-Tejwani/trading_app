import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/features/holdings/data/portfolio_repository.dart';
import 'package:trading_app/features/holdings/domain/entities/holding.dart';
import 'package:trading_app/features/order/presentation/bloc/order_bloc.dart';

import 'test_helpers.dart';

void main() {
  late PortfolioRepository portfolio;
  late dynamic feed;

  setUp(() async {
    portfolio = PortfolioRepository(await createStorage());
    await portfolio.load();
    feed = createFeed();
    feed.start();
  });

  tearDown(() async {
    await feed.dispose();
    await portfolio.dispose();
  });

  test('event updates are no-ops before initialization', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);

    bloc.add(const OrderSideToggled(OrderSide.sell));
    bloc.add(OrderQuantityChanged(Decimal.fromInt(2)));
    bloc.add(OrderPriceRefreshed(Decimal.fromInt(2)));
    bloc.add(const OrderSubmitted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state, OrderState.empty());
    await bloc.close();
  });

  test('uses the singleton feed when no feed is supplied', () async {
    final bloc = OrderBloc(portfolio, l10n: english());
    await bloc.close();
  });

  test('initializes known symbols and reports unknown symbols', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);

    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    expect(bloc.state.draft!.symbol, 'RELIANCE');
    expect(bloc.state.draft!.quantity, Decimal.one);
    expect(bloc.state.draft!.side, OrderSide.buy);

    bloc.add(const OrderInitialized('NOTREAL'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.error, english().unknownSymbol('NOTREAL'));
    await bloc.close();
  });

  test('updates side, quantity, and price while clearing errors', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;

    bloc.add(const OrderSideToggled(OrderSide.sell));
    bloc.add(OrderQuantityChanged(Decimal.parse('1.25')));
    bloc.add(OrderPriceRefreshed(Decimal.fromInt(3000)));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.draft!.side, OrderSide.sell);
    expect(bloc.state.draft!.quantity, Decimal.parse('1.25'));
    expect(bloc.state.draft!.price, Decimal.fromInt(3000));
    await bloc.close();
  });

  test('rejects a zero quantity with its specific validation message',
      () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    bloc.add(OrderQuantityChanged(Decimal.zero));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    final state = await bloc.stream.first;
    expect(state.error, english().quantityMustBeGreaterThanZero);
    await bloc.close();
  });

  test('rejects zero, negative, and over-precise quantities', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;

    for (final quantity in [
      Decimal.zero,
      Decimal.fromInt(-1),
      Decimal.parse('1.12345')
    ]) {
      bloc.add(OrderQuantityChanged(quantity));
      await bloc.stream.first;
      bloc.add(const OrderSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.error, isNotNull);
    }
    expect(bloc.state.error, english().quantityMaxDecimals);
    await bloc.close();
  });

  test('rejects a buy when the balance is insufficient', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    bloc.add(OrderQuantityChanged(Decimal.fromInt(1000000)));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.error, contains('Insufficient balance'));
    expect(bloc.state.lastOrder, isNull);
    await bloc.close();
  });

  test('rejects selling missing or insufficient holdings', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    bloc.add(const OrderSideToggled(OrderSide.sell));
    bloc.add(const OrderSubmitted());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.error, contains('Insufficient quantity'));

    await bloc.close();
  });

  test('rejects selling more than the held quantity', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;

    // Buy a small amount first so a non-empty holding exists.
    bloc.add(OrderQuantityChanged(Decimal.parse('0.5')));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    await bloc.stream.firstWhere((s) => s.lastOrder != null);

    // Now try to sell more than what's held.
    bloc.add(const OrderSideToggled(OrderSide.sell));
    bloc.add(OrderQuantityChanged(Decimal.parse('5')));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.error, contains('Insufficient quantity'));
    await bloc.close();
  });

  test('executes a buy and then a sell using the live price', () async {
    final bloc = OrderBloc(portfolio, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    bloc.add(OrderQuantityChanged(Decimal.parse('0.5')));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    await bloc.stream.firstWhere((s) => s.lastOrder != null);

    expect(bloc.state.lastOrder!.side, OrderSide.buy);
    expect(bloc.state.submitting, isFalse);
    expect(portfolio.holdings.single.quantity, Decimal.parse('0.5'));

    bloc.add(const OrderSideToggled(OrderSide.sell));
    bloc.add(const OrderSubmitted());
    await bloc.stream.firstWhere((s) => s.lastOrder!.side == OrderSide.sell);
    expect(portfolio.holdings, isEmpty);
    await bloc.close();
  });

  test('catches repository errors during submission', () async {
    final failing = _ThrowingPortfolioRepository(await createStorage());
    final bloc = OrderBloc(failing, l10n: english(), feed: feed);
    bloc.add(const OrderInitialized('RELIANCE'));
    await bloc.stream.first;
    bloc.add(const OrderSubmitted());
    await bloc.stream.firstWhere((s) => s.error != null);

    expect(bloc.state.error, 'Bad state: Bad order');
    await bloc.close();
    await failing.dispose();
  });
}

class _ThrowingPortfolioRepository extends PortfolioRepository {
  _ThrowingPortfolioRepository(super.storage);

  @override
  Future<Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required Decimal quantity,
    required Decimal price,
  }) async {
    throw StateError('Bad order');
  }
}

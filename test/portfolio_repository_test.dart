import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/app_constants.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/features/holdings/data/portfolio_repository.dart';

import 'test_helpers.dart';

void main() {
  test('loads defaults, emits snapshots, and ignores repeated loads', () async {
    final repository = PortfolioRepository(await createStorage());
    final holdings = <List<dynamic>>[];
    final orders = <List<dynamic>>[];
    final balances = <Decimal>[];
    final holdingsSub = repository.holdingsStream.listen(holdings.add);
    final ordersSub = repository.ordersStream.listen(orders.add);
    final balanceSub = repository.balanceStream.listen(balances.add);

    await repository.load();
    await Future<void>.delayed(Duration.zero);
    await repository.load();

    expect(repository.balance, AppConstants.initialWalletBalance);
    expect(repository.holdings, isEmpty);
    expect(repository.orders, isEmpty);
    expect(holdings, hasLength(1));
    expect(orders, hasLength(1));
    expect(balances, [AppConstants.initialWalletBalance]);

    await holdingsSub.cancel();
    await ordersSub.cancel();
    await balanceSub.cancel();
    await repository.dispose();
  });

  test('loads persisted wallet, holdings, and orders', () async {
    final storedHolding = holding(quantity: '3', avgCost: '125');
    final storedOrder = order(quantity: '3', price: '125', value: '375');
    final storage = await createStorage();
    await storage.saveWallet({'balance': '999'});
    await storage.saveHoldings([storedHolding.toJson()]);
    await storage.saveOrders([storedOrder.toJson()]);
    final repository = PortfolioRepository(storage);

    await repository.load();
    await repository.load();

    expect(repository.balance, Decimal.parse('999'));
    expect(repository.holdings, [storedHolding]);
    expect(repository.orders, [storedOrder]);
    await repository.dispose();
  });

  test('places a buy for a new holding and persists it', () async {
    final repository = PortfolioRepository(await createStorage());

    final placed = await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.parse('2'),
      price: Decimal.parse('100.25'),
    );

    expect(placed.side, OrderSide.buy);
    expect(placed.value, Decimal.parse('200.50'));
    expect(repository.balance, Decimal.parse('999799.50'));
    expect(repository.holdings, [holding(quantity: '2', avgCost: '100.25')]);
    expect(repository.orders.single, placed);
    await repository.dispose();
  });

  test('averages a buy into an existing holding', () async {
    final repository = PortfolioRepository(await createStorage());
    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.parse('2'),
      price: Decimal.parse('100'),
    );

    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.parse('1'),
      price: Decimal.parse('130'),
    );

    expect(repository.holdings.single.quantity, Decimal.parse('3'));
    expect(repository.holdings.single.avgCost, Decimal.parse('110'));
    expect(repository.orders, hasLength(2));
    await repository.dispose();
  });

  test('partially and fully sells a holding', () async {
    final repository = PortfolioRepository(await createStorage());
    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.parse('3'),
      price: Decimal.parse('100'),
    );

    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.sell,
      quantity: Decimal.parse('1'),
      price: Decimal.parse('120'),
    );
    expect(repository.holdings.single.quantity, Decimal.parse('2'));
    expect(repository.balance, Decimal.parse('999820'));

    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.sell,
      quantity: Decimal.parse('2'),
      price: Decimal.parse('80'),
    );
    expect(repository.holdings, isEmpty);
    expect(repository.balance, Decimal.parse('999980'));
    expect(repository.orders, hasLength(3));
    await repository.dispose();
  });

  test('rejects selling an unknown or insufficient holding', () async {
    final repository = PortfolioRepository(await createStorage());

    expect(
      () => repository.placeOrder(
        symbol: 'UNKNOWN',
        side: OrderSide.sell,
        quantity: Decimal.one,
        price: Decimal.one,
      ),
      throwsA(isA<StateError>()),
    );

    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.one,
      price: Decimal.fromInt(100),
    );

    expect(
      () => repository.placeOrder(
        symbol: 'RELIANCE',
        side: OrderSide.sell,
        quantity: Decimal.fromInt(2),
        price: Decimal.fromInt(100),
      ),
      throwsA(isA<StateError>()),
    );
    await repository.dispose();
  });

  test('resetWallet clears all persisted state and emits it', () async {
    final repository = PortfolioRepository(await createStorage());
    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.one,
      price: Decimal.fromInt(100),
    );
    final balances = <Decimal>[];
    final subscription = repository.balanceStream.listen(balances.add);

    await repository.resetWallet();
    await Future<void>.delayed(Duration.zero);

    expect(repository.balance, AppConstants.initialWalletBalance);
    expect(repository.holdings, isEmpty);
    expect(repository.orders, isEmpty);
    expect(balances, [AppConstants.initialWalletBalance]);
    await subscription.cancel();
    await repository.dispose();
  });

  test('dispose closes all repository streams', () async {
    final repository = PortfolioRepository(await createStorage());
    await repository.dispose();

    expect(repository.holdingsStream.isBroadcast, isTrue);
    expect(repository.ordersStream.isBroadcast, isTrue);
    expect(repository.balanceStream.isBroadcast, isTrue);
  });
}

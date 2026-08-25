import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/decimal_utils.dart';
import '../domain/entities/holding.dart';

class PortfolioRepository {
  PortfolioRepository(this._storage);

  final LocalStorage _storage;
  final _watchlistsController = StreamController<List<Holding>>.broadcast();
  final _ordersController = StreamController<List<Order>>.broadcast();
  final _balanceController = StreamController<Decimal>.broadcast();
  final _uuid = const Uuid();

  Decimal _balance = AppConstants.initialWalletBalance;
  List<Holding> _holdings = [];
  List<Order> _orders = [];
  bool _loaded = false;

  Stream<List<Holding>> get holdingsStream => _watchlistsController.stream;
  Stream<List<Order>> get ordersStream => _ordersController.stream;
  Stream<Decimal> get balanceStream => _balanceController.stream;

  Decimal get balance => _balance;
  List<Holding> get holdings => List.unmodifiable(_holdings);
  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> load() async {
    if (_loaded) return;
    final rawBalance = _storage.readWallet();
    if (rawBalance != null && rawBalance['balance'] != null) {
      _balance = Decimal.parse(rawBalance['balance'] as String);
    } else {
      await _persistWallet();
    }
    final rawHoldings = _storage.readHoldings();
    if (rawHoldings != null) {
      _holdings = rawHoldings.map(Holding.fromJson).toList();
    }
    final rawOrders = _storage.readOrders();
    if (rawOrders != null) {
      _orders = rawOrders.map(Order.fromJson).toList();
    }
    _loaded = true;
    _emitAll();
  }

  Future<Order> placeOrder({
    required String symbol,
    required OrderSide side,
    required Decimal quantity,
    required Decimal price,
  }) async {
    final value = Decimal.parse((quantity * price).toString());
    if (side == OrderSide.buy) {
      _balance -= value;
      final existing = _holdings.where((h) => h.symbol == symbol).toList();
      if (existing.isEmpty) {
        _holdings = [
          ..._holdings,
          Holding(symbol: symbol, quantity: quantity, avgCost: price),
        ];
      } else {
        final cur = existing.first;
        final totalQty = cur.quantity + quantity;
        final totalCost = cur.quantity * cur.avgCost + quantity * price;
        final newAvg = DecimalUtils.divide(totalCost, totalQty, scale: 8);
        _holdings = _holdings
            .map(
              (h) => h.symbol == symbol
                  ? Holding(symbol: symbol, quantity: totalQty, avgCost: newAvg)
                  : h,
            )
            .toList();
      }
    } else {
      final existing = _holdings.where((h) => h.symbol == symbol).toList();
      if (existing.isEmpty) {
        throw StateError('No holding for $symbol');
      }
      final cur = existing.first;
      if (cur.quantity < quantity) {
        throw StateError('Insufficient quantity to sell');
      }
      final remaining = cur.quantity - quantity;
      _balance += value;
      if (remaining == Decimal.zero) {
        _holdings = _holdings.where((h) => h.symbol != symbol).toList();
      } else {
        _holdings = _holdings
            .map(
              (h) => h.symbol == symbol ? cur.copyWithQuantity(remaining) : h,
            )
            .toList();
      }
    }
    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: side,
      quantity: quantity,
      price: price,
      value: value,
      timestamp: DateTime.now(),
    );
    _orders = [order, ..._orders];
    await _persistAll();
    return order;
  }

  Future<void> resetWallet() async {
    _balance = AppConstants.initialWalletBalance;
    _holdings = [];
    _orders = [];
    await _persistAll();
  }

  Future<void> _persistAll() async {
    await _persistWallet();
    await _storage.saveHoldings(_holdings.map((h) => h.toJson()).toList());
    await _storage.saveOrders(_orders.map((o) => o.toJson()).toList());
    _emitAll();
  }

  Future<void> _persistWallet() async {
    await _storage.saveWallet({'balance': _balance.toString()});
  }

  void _emitAll() {
    if (!_watchlistsController.isClosed) {
      _watchlistsController.add(List.unmodifiable(_holdings));
    }
    if (!_ordersController.isClosed) {
      _ordersController.add(List.unmodifiable(_orders));
    }
    if (!_balanceController.isClosed) _balanceController.add(_balance);
  }

  Future<void> dispose() async {
    await _watchlistsController.close();
    await _ordersController.close();
    await _balanceController.close();
  }
}

extension on Holding {
  Holding copyWithQuantity(Decimal q) =>
      Holding(symbol: symbol, quantity: q, avgCost: avgCost);
}

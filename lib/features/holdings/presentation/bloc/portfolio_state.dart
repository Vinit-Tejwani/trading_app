import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:trading_app/core/constants/enum.dart';

import '../../domain/entities/holding.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override
  List<Object?> get props => [];
}

class PortfolioStarted extends PortfolioEvent {
  const PortfolioStarted();
}

class PortfolioHoldingsUpdated extends PortfolioEvent {
  final List<Holding> holdings;
  const PortfolioHoldingsUpdated(this.holdings);
  @override
  List<Object?> get props => [holdings];
}

class PortfolioBalanceUpdated extends PortfolioEvent {
  final Decimal balance;
  const PortfolioBalanceUpdated(this.balance);
  @override
  List<Object?> get props => [balance];
}

class HoldingsSortChanged extends PortfolioEvent {
  final HoldingsSort sort;
  const HoldingsSortChanged(this.sort);
  @override
  List<Object?> get props => [sort];
}

class PortfolioState extends Equatable {
  final List<Holding> holdings;
  final Decimal balance;
  final HoldingsSort sort;
  final bool loading;

  const PortfolioState({
    required this.holdings,
    required this.balance,
    required this.sort,
    required this.loading,
  });

  factory PortfolioState.initial() => PortfolioState(
        holdings: const [],
        balance: Decimal.zero,
        sort: HoldingsSort.pnlDesc,
        loading: true,
      );

  PortfolioState copyWith({
    List<Holding>? holdings,
    Decimal? balance,
    HoldingsSort? sort,
    bool? loading,
  }) {
    return PortfolioState(
      holdings: holdings ?? this.holdings,
      balance: balance ?? this.balance,
      sort: sort ?? this.sort,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [holdings, balance, sort, loading];
}

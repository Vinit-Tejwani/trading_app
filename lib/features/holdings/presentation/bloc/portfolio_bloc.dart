import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/portfolio_repository.dart';
import '../../domain/entities/holding.dart';
import 'portfolio_state.dart';

export 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc(this._repo) : super(PortfolioState.initial()) {
    on<PortfolioStarted>(_onStarted);
    on<PortfolioHoldingsUpdated>(_onHoldings);
    on<PortfolioBalanceUpdated>(_onBalance);
    on<HoldingsSortChanged>(
        (event, emit) => emit(state.copyWith(sort: event.sort)));
  }

  final PortfolioRepository _repo;
  StreamSubscription<List<Holding>>? _holdingsSub;
  StreamSubscription<Decimal>? _balanceSub;

  Future<void> _onStarted(
    PortfolioStarted event,
    Emitter<PortfolioState> emit,
  ) async {
    await _repo.load();
    emit(
      PortfolioState(
        holdings: _repo.holdings,
        balance: _repo.balance,
        sort: state.sort,
        loading: false,
      ),
    );

    await _holdingsSub?.cancel();
    _holdingsSub = _repo.holdingsStream.listen(
      (holdings) => add(PortfolioHoldingsUpdated(holdings)),
    );
    await _balanceSub?.cancel();
    _balanceSub = _repo.balanceStream.listen(
      (balance) => add(PortfolioBalanceUpdated(balance)),
    );
  }

  void _onHoldings(
    PortfolioHoldingsUpdated event,
    Emitter<PortfolioState> emit,
  ) {
    emit(state.copyWith(holdings: event.holdings));
  }

  void _onBalance(
    PortfolioBalanceUpdated event,
    Emitter<PortfolioState> emit,
  ) {
    emit(state.copyWith(balance: event.balance));
  }

  @override
  Future<void> close() async {
    await _holdingsSub?.cancel();
    await _balanceSub?.cancel();
    return super.close();
  }
}

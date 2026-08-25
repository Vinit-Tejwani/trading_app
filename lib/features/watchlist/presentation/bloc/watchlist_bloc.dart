import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/watchlist_repository.dart';
import '../../domain/entities/watchlist.dart';
import 'watchlist_state.dart';

export 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc(this._repo) : super(WatchlistState.initial()) {
    on<WatchlistsLoaded>(_onLoaded);
    on<WatchlistsUpdated>(_onUpdated);
    on<WatchlistCreated>((e, _) => _repo.create(e.name));
    on<WatchlistRenamed>((e, _) => _repo.rename(e.id, e.name));
    on<WatchlistDeleted>((e, _) => _repo.delete(e.id));
    on<SymbolAddedToWatchlist>(
        (e, _) => _repo.addSymbol(e.watchlistId, e.symbol));
    on<SymbolRemovedFromWatchlist>(
        (e, _) => _repo.removeSymbol(e.watchlistId, e.symbol));
    on<SymbolsReordered>(
        (e, _) => _repo.reorderSymbols(e.watchlistId, e.oldIndex, e.newIndex));
  }

  final WatchlistRepository _repo;
  StreamSubscription<List<Watchlist>>? _sub;

  Future<void> _onLoaded(
    WatchlistsLoaded event,
    Emitter<WatchlistState> emit,
  ) async {
    await _repo.load();
    emit(state.copyWith(watchlists: _repo.current, loading: false));
    await _sub?.cancel();
    _sub = _repo.stream.listen((list) {
      if (!isClosed) add(WatchlistsUpdated(list));
    });
  }

  void _onUpdated(WatchlistsUpdated event, Emitter<WatchlistState> emit) {
    emit(state.copyWith(watchlists: event.watchlists));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

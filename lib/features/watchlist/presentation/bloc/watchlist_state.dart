import 'package:equatable/equatable.dart';

import '../../domain/entities/watchlist.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object?> get props => [];
}

class WatchlistsLoaded extends WatchlistEvent {
  const WatchlistsLoaded();
}

class WatchlistsUpdated extends WatchlistEvent {
  final List<Watchlist> watchlists;
  const WatchlistsUpdated(this.watchlists);
  @override
  List<Object?> get props => [watchlists];
}

class WatchlistCreated extends WatchlistEvent {
  final String name;
  const WatchlistCreated(this.name);
  @override
  List<Object?> get props => [name];
}

class WatchlistRenamed extends WatchlistEvent {
  final String id;
  final String name;
  const WatchlistRenamed(this.id, this.name);
  @override
  List<Object?> get props => [id, name];
}

class WatchlistDeleted extends WatchlistEvent {
  final String id;
  const WatchlistDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class SymbolAddedToWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;
  const SymbolAddedToWatchlist(this.watchlistId, this.symbol);
  @override
  List<Object?> get props => [watchlistId, symbol];
}

class SymbolRemovedFromWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;
  const SymbolRemovedFromWatchlist(this.watchlistId, this.symbol);
  @override
  List<Object?> get props => [watchlistId, symbol];
}

class SymbolsReordered extends WatchlistEvent {
  final String watchlistId;
  final int oldIndex;
  final int newIndex;
  const SymbolsReordered(this.watchlistId, this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [watchlistId, oldIndex, newIndex];
}

class WatchlistState extends Equatable {
  final List<Watchlist> watchlists;
  final bool loading;

  const WatchlistState({required this.watchlists, required this.loading});

  factory WatchlistState.initial() =>
      const WatchlistState(watchlists: [], loading: true);

  WatchlistState copyWith({List<Watchlist>? watchlists, bool? loading}) =>
      WatchlistState(
        watchlists: watchlists ?? this.watchlists,
        loading: loading ?? this.loading,
      );

  @override
  List<Object?> get props => [watchlists, loading];
}

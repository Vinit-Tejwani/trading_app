import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../core/storage/local_storage.dart';
import '../domain/entities/watchlist.dart';

class WatchlistRepository {
  WatchlistRepository(
    this._storage, {
    String defaultWatchlistName = 'My Watchlist',
    String newWatchlistFallbackName = 'New Watchlist',
  })  : _defaultWatchlistName = defaultWatchlistName,
        _newWatchlistFallbackName = newWatchlistFallbackName;

  final LocalStorage _storage;
  final String _defaultWatchlistName;
  final String _newWatchlistFallbackName;
  final _controller = StreamController<List<Watchlist>>.broadcast();
  final _uuid = const Uuid();

  List<Watchlist> _watchlists = [];
  bool _loaded = false;

  Stream<List<Watchlist>> get stream => _controller.stream;
  List<Watchlist> get current => List.unmodifiable(_watchlists);

  Future<void> load() async {
    if (_loaded) return;
    final raw = _storage.readWatchlists();
    if (raw == null || raw.isEmpty) {
      _watchlists = [
        Watchlist(
          id: _uuid.v4(),
          name: _defaultWatchlistName,
          symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK'],
          createdAt: DateTime.now(),
        ),
      ];
      await _persist();
    } else {
      _watchlists = raw.map(Watchlist.fromJson).toList();
    }
    _loaded = true;
    _emit();
  }

  Future<Watchlist> create(String name) async {
    final wl = Watchlist(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? _newWatchlistFallbackName : name.trim(),
      symbols: const [],
      createdAt: DateTime.now(),
    );
    _watchlists = [..._watchlists, wl];
    await _persist();
    return wl;
  }

  Future<void> rename(String id, String name) async {
    _watchlists = _watchlists
        .map((w) => w.id == id ? w.copyWith(name: name.trim()) : w)
        .toList();
    await _persist();
  }

  Future<void> delete(String id) async {
    // Deleting the last list is valid. The UI then shows the empty state and
    // the user can create a fresh list instead of silently recreating one.
    _watchlists = _watchlists.where((w) => w.id != id).toList();
    await _persist();
  }

  Future<void> addSymbol(String watchlistId, String symbol) async {
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      if (w.symbols.contains(symbol)) return w;
      return w.copyWith(symbols: [...w.symbols, symbol]);
    }).toList();
    await _persist();
  }

  Future<void> removeSymbol(String watchlistId, String symbol) async {
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      return w.copyWith(symbols: w.symbols.where((s) => s != symbol).toList());
    }).toList();
    await _persist();
  }

  Future<void> reorderSymbols(
    String watchlistId,
    int oldIndex,
    int newIndex,
  ) async {
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      final list = [...w.symbols];
      var ni = newIndex;
      if (ni > oldIndex) ni -= 1;
      final moved = list.removeAt(oldIndex);
      list.insert(ni, moved);
      return w.copyWith(symbols: list);
    }).toList();
    await _persist();
  }

  Watchlist? byId(String id) {
    for (final w in _watchlists) {
      if (w.id == id) return w;
    }
    return null;
  }

  Future<void> _persist() async {
    await _storage.saveWatchlists(_watchlists.map((w) => w.toJson()).toList());
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_watchlists));
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

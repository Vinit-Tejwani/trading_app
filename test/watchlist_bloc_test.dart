import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/features/watchlist/data/watchlist_repository.dart';
import 'package:trading_app/features/watchlist/presentation/bloc/watchlist_bloc.dart';

import 'test_helpers.dart';

void main() {
  late WatchlistRepository repository;

  setUp(() async {
    repository = WatchlistRepository(await createStorage());
    await repository.load();
  });

  tearDown(() async {
    await repository.dispose();
  });

  blocTest<WatchlistBloc, WatchlistState>(
    'starts in loading state',
    build: () => WatchlistBloc(repository),
    expect: () => <WatchlistState>[],
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'loads the repository and subscribes to updates',
    build: () => WatchlistBloc(repository),
    act: (bloc) async {
      bloc.add(const WatchlistsLoaded());
      await bloc.stream.first;
      await repository.create('Created');
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<WatchlistState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.watchlists.length, 'count', 1),
      isA<WatchlistState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.watchlists.length, 'count', 2),
    ],
  );

  blocTest<WatchlistBloc, WatchlistState>(
    'handles every repository command event',
    build: () => WatchlistBloc(repository),
    act: (bloc) async {
      final id = repository.current.single.id;
      bloc.add(const WatchlistsLoaded());
      await bloc.stream.first;
      bloc.add(WatchlistCreated('New'));
      await Future<void>.delayed(Duration.zero);
      final newId = repository.current.last.id;
      bloc.add(WatchlistRenamed(newId, 'Renamed'));
      bloc.add(SymbolAddedToWatchlist(newId, 'SBIN'));
      bloc.add(SymbolRemovedFromWatchlist(newId, 'SBIN'));
      bloc.add(SymbolsReordered(id, 0, 0));
      bloc.add(WatchlistDeleted(newId));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    },
    expect: () => [
      isA<WatchlistState>().having((s) => s.loading, 'loading', false),
      isA<WatchlistState>().having((s) => s.watchlists.length, 'created', 2),
      isA<WatchlistState>().having(
        (s) => s.watchlists.any((w) => w.name == 'Renamed'),
        'renamed',
        true,
      ),
      isA<WatchlistState>().having(
        (s) => s.watchlists.any((w) => w.symbols.contains('SBIN')),
        'added',
        true,
      ),
      isA<WatchlistState>().having(
        (s) => s.watchlists.every((w) => !w.symbols.contains('SBIN')),
        'removed',
        true,
      ),
      isA<WatchlistState>().having((s) => s.watchlists.length, 'deleted', 1),
    ],
  );

  test('updated event replaces the list without changing loading', () async {
    final bloc = WatchlistBloc(repository);
    final replacement = [
      watchlist(id: 'replacement', symbols: ['ITC'])
    ];
    final states = <WatchlistState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(WatchlistsUpdated(replacement));
    await Future<void>.delayed(Duration.zero);

    expect(states.single.watchlists, replacement);
    expect(states.single.loading, isTrue);
    await subscription.cancel();
    await bloc.close();
  });

  test('close cancels its repository subscription', () async {
    final bloc = WatchlistBloc(repository);
    bloc.add(const WatchlistsLoaded());
    await bloc.stream.first;
    await bloc.close();
    await repository.create('After close');
    expect(bloc.isClosed, isTrue);
  });
}

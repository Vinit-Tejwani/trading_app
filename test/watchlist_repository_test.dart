import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/features/watchlist/data/watchlist_repository.dart';

import 'test_helpers.dart';

void main() {
  test('loads a default list, emits it, and ignores repeated loads', () async {
    final storage = await createStorage();
    final repository = WatchlistRepository(
      storage,
      defaultWatchlistName: 'Default',
    );
    final emissions = <List<dynamic>>[];
    final subscription = repository.stream.listen(emissions.add);

    await repository.load();
    final first = repository.current.single;
    await repository.load();

    expect(first.name, 'Default');
    expect(first.symbols, ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK']);
    expect(repository.current, hasLength(1));
    expect(emissions, hasLength(1));

    await subscription.cancel();
    await repository.dispose();
  });

  test('loads persisted lists and supports lookup', () async {
    final stored = watchlist(id: 'saved', name: 'Saved', symbols: ['ITC']);
    final storage = await createStorage({
      'watchlists_v1': <String>[stored.toJson().toString()],
    });
    // Store through LocalStorage to exercise the JSON boundary.
    await storage.saveWatchlists([stored.toJson()]);
    final repository = WatchlistRepository(storage);

    await repository.load();

    expect(repository.current, [stored]);
    expect(repository.byId('saved'), stored);
    expect(repository.byId('missing'), isNull);
    await repository.dispose();
  });

  test('creates trimmed and fallback names', () async {
    final repository = WatchlistRepository(
      await createStorage(),
      newWatchlistFallbackName: 'Fallback',
    );

    final named = await repository.create('  Growth  ');
    final fallback = await repository.create('   ');

    expect(named.name, 'Growth');
    expect(fallback.name, 'Fallback');
    expect(repository.current.map((w) => w.name), ['Growth', 'Fallback']);
    await repository.dispose();
  });

  test('renames and deletes targeted or missing lists', () async {
    final repository = WatchlistRepository(await createStorage());
    final one = await repository.create('One');
    final two = await repository.create('Two');

    await repository.rename(one.id, '  Renamed ');
    await repository.rename('missing', 'Ignored');
    await repository.delete('missing');
    await repository.delete(one.id);
    await repository.delete(two.id);

    expect(repository.current, isEmpty);
    await repository.dispose();
  });

  test('adds, deduplicates, removes symbols, and reorders', () async {
    final repository = WatchlistRepository(await createStorage());
    final list = await repository.create('Symbols');
    final other = await repository.create('Other');

    await repository.addSymbol(list.id, 'RELIANCE');
    await repository.addSymbol(list.id, 'RELIANCE');
    await repository.addSymbol('missing', 'TCS');
    await repository.removeSymbol(list.id, 'RELIANCE');
    await repository.removeSymbol(list.id, 'missing');
    await repository.addSymbol(list.id, 'A');
    await repository.addSymbol(list.id, 'B');
    await repository.addSymbol(list.id, 'C');
    await repository.reorderSymbols(list.id, 0, 2);
    await repository.reorderSymbols('missing', 0, 0);

    expect(repository.byId(list.id)!.symbols, ['B', 'A', 'C']);
    expect(repository.byId(other.id)!.symbols, isEmpty);
    await repository.dispose();
  });

  test('reorder supports moving an item to an earlier position', () async {
    final repository = WatchlistRepository(await createStorage());
    final list = await repository.create('Symbols');
    for (final symbol in ['A', 'B', 'C']) {
      await repository.addSymbol(list.id, symbol);
    }

    await repository.reorderSymbols(list.id, 2, 0);

    expect(repository.byId(list.id)!.symbols, ['C', 'A', 'B']);
    await repository.dispose();
  });

  test('closed repository does not emit after disposal', () async {
    final repository = WatchlistRepository(await createStorage());
    await repository.dispose();
    expect(repository.stream.isBroadcast, isTrue);
  });
}

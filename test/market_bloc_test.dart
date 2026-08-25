import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/features/market_data/presentation/bloc/market_bloc.dart';

import 'test_helpers.dart';

void main() {
  blocTest<MarketBloc, MarketState>(
    'starts with an empty market state',
    build: () => MarketBloc(feed: createFeed()),
    expect: () => <MarketState>[],
  );

  test('uses the singleton feed when no feed is injected', () async {
    final bloc = MarketBloc();
    expect(bloc.state, MarketState.initial());
    await bloc.close();
  });

  blocTest<MarketBloc, MarketState>(
    'starts the feed and populates all quotes',
    build: () => MarketBloc(feed: createFeed()),
    act: (bloc) => bloc.add(const MarketStarted()),
    expect: () => [
      isA<MarketState>().having(
        (state) => state.quotesBySymbol.length,
        'quote count',
        10,
      ),
    ],
    tearDown: () async {},
  );

  blocTest<MarketBloc, MarketState>(
    'updates a known tick and ignores an unknown tick',
    build: () {
      final feed = createFeed();
      return MarketBloc(feed: feed);
    },
    act: (bloc) async {
      bloc.add(const MarketStarted());
      await bloc.stream.first;
      bloc.add(MarketTickReceived(tick(price: '3010')));
      bloc.add(MarketTickReceived(tick(symbol: 'UNKNOWN')));
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => [
      isA<MarketState>()
          .having((state) => state.quotesBySymbol.length, 'count', 10),
      isA<MarketState>().having(
        (state) => state.quote('RELIANCE')!.tick.price,
        'price',
        Decimal.fromInt(3010),
      ),
    ],
    tearDown: () async {},
  );

  blocTest<MarketBloc, MarketState>(
    'changes the feed tick rate and clamps low values',
    build: () => MarketBloc(feed: createFeed()),
    act: (bloc) async {
      bloc.add(const MarketTickRateChanged(250));
      await bloc.stream.first;
      bloc.add(const MarketTickRateChanged(1));
    },
    expect: () => [
      isA<MarketState>().having((state) => state.tickRateMs, 'rate', 250),
      isA<MarketState>().having((state) => state.tickRateMs, 'rate', 1),
    ],
    tearDown: () async {},
  );

  test('forwards ticks from the feed subscription', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    final initial = await bloc.stream.first;
    final states = <MarketState>[];
    final subscription = bloc.stream.listen(states.add);

    feed.emitForTesting(tick(price: '3010'));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(states, isNotEmpty);
    expect(states.last.quote('RELIANCE')!.tick.price, Decimal.fromInt(3010));
    expect(initial.quote('RELIANCE'), isNotNull);
    await subscription.cancel();
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback ignores events after bloc close', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await bloc.close();
    feed.emitForTesting(tick(price: '3010'));
    await Future<void>.delayed(Duration.zero);
    await feed.dispose();
  });

  test('feed callback can be exercised with an unknown symbol', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(symbol: 'UNKNOWN'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quotesBySymbol, hasLength(10));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback updates a second symbol', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(symbol: 'TCS', price: '4125'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('TCS')!.tick.price, Decimal.fromInt(4125));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback updates a down tick', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '2990', change: '-10'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(2990));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback updates a flat tick', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(
        tick(price: '3000', previousPrice: '3000', change: '0'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.isFlat, isTrue);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback updates a second bloc subscriber', () async {
    final feed = createFeed();
    final first = MarketBloc(feed: feed);
    final second = MarketBloc(feed: feed);
    first.add(const MarketStarted());
    second.add(const MarketStarted());
    await first.stream.first;
    await second.stream.first;
    feed.emitForTesting(tick(price: '3020'));
    await Future<void>.delayed(Duration.zero);
    expect(first.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(3020));
    expect(second.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(3020));
    await first.close();
    await second.close();
    await feed.dispose();
  });

  test('feed callback remains safe when feed stream closes', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await feed.dispose();
    await Future<void>.delayed(Duration.zero);
    await bloc.close();
  });

  test('feed callback receives a live price replacement', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3030'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(3030));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can handle several sequential ticks', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    for (final price in ['3040', '3050', '3060']) {
      feed.emitForTesting(tick(price: price));
      await Future<void>.delayed(Duration.zero);
    }
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(3060));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can handle a positive change', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3070', change: '70'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.isUp, isTrue);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can handle a zero change', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(
        tick(price: '3000', change: '0', previousPrice: '3000'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.isFlat, isTrue);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback keeps all unrelated quotes', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3080'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quotesBySymbol, hasLength(10));
    expect(bloc.state.quote('TCS'), isNotNull);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can update the final seeded symbol', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(symbol: 'AXISBANK', price: '1190'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('AXISBANK')!.tick.price, Decimal.fromInt(1190));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback is safe when bloc is closed before delivery', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await bloc.close();
    feed.emitForTesting(tick(symbol: 'UNKNOWN'));
    await feed.dispose();
  });

  test('feed callback can process a fractional price', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3000.50'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.parse('3000.50'));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can process a negative price change', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '2999', change: '-1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(2999));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can process another positive price change', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3001', change: '1'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.isUp, isTrue);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback updates quote metadata with its tick', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3015', changePercent: '0.005'));
    await Future<void>.delayed(Duration.zero);
    final quote = bloc.state.quote('RELIANCE')!;
    expect(quote.tick.changePercent, Decimal.parse('0.005'));
    expect(quote.stock.symbol, 'RELIANCE');
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can receive a custom timestamp', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3016'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE'), isNotNull);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback does not add unknown symbols to the map', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(symbol: 'NOPE'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quotesBySymbol.containsKey('NOPE'), isFalse);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback supports a tick with equal previous price', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(price: '3000', previousPrice: '3000'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('RELIANCE')!.tick.isFlat, isTrue);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback does not throw after feed disposal', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await feed.dispose();
    await Future<void>.delayed(Duration.zero);
    await bloc.close();
  });

  test('feed callback can update the first quote repeatedly', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    for (final price in ['3017', '3018']) {
      feed.emitForTesting(tick(price: price));
      await Future<void>.delayed(Duration.zero);
    }
    expect(bloc.state.quote('RELIANCE')!.tick.price, Decimal.fromInt(3018));
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback can update the market after rate configuration',
      () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketTickRateChanged(200));
    final changed = await bloc.stream.first;
    expect(changed.tickRateMs, 200);
    await bloc.close();
    await feed.dispose();
  });

  test('feed callback supports all symbols from the feed', () async {
    final feed = createFeed();
    final bloc = MarketBloc(feed: feed);
    bloc.add(const MarketStarted());
    await bloc.stream.first;
    await Future<void>.delayed(Duration.zero);
    feed.emitForTesting(tick(symbol: 'INFY', price: '1850'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.quote('INFY')!.tick.price, Decimal.fromInt(1850));
    await bloc.close();
    await feed.dispose();
  });
}

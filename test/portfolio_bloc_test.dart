import 'package:bloc_test/bloc_test.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/features/holdings/data/portfolio_repository.dart';
import 'package:trading_app/features/holdings/presentation/bloc/portfolio_bloc.dart';

import 'test_helpers.dart';

void main() {
  late PortfolioRepository repository;

  setUp(() async {
    repository = PortfolioRepository(await createStorage());
  });

  tearDown(() async {
    await repository.dispose();
  });

  blocTest<PortfolioBloc, PortfolioState>(
    'starts with the initial loading state',
    build: () => PortfolioBloc(repository),
    expect: () => <PortfolioState>[],
  );

  blocTest<PortfolioBloc, PortfolioState>(
    'loads holdings and balance while preserving the default sort',
    build: () => PortfolioBloc(repository),
    act: (bloc) => bloc.add(const PortfolioStarted()),
    expect: () => [
      isA<PortfolioState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.holdings, 'holdings', isEmpty)
          .having((s) => s.balance, 'balance', Decimal.fromInt(1000000))
          .having((s) => s.sort, 'sort', HoldingsSort.pnlDesc),
    ],
  );

  blocTest<PortfolioBloc, PortfolioState>(
    'handles explicit holding, balance, and sort events',
    build: () => PortfolioBloc(repository),
    act: (bloc) async {
      bloc.add(const PortfolioStarted());
      await bloc.stream.first;
      bloc.add(PortfolioHoldingsUpdated([holding(quantity: '4')]));
      bloc.add(PortfolioBalanceUpdated(Decimal.fromInt(777)));
      bloc.add(const HoldingsSortChanged(HoldingsSort.symbol));
      await Future<void>.delayed(const Duration(milliseconds: 10));
    },
    expect: () => [
      isA<PortfolioState>().having((s) => s.loading, 'loaded', false),
      isA<PortfolioState>().having(
          (s) => s.holdings.single.quantity, 'quantity', Decimal.fromInt(4)),
      isA<PortfolioState>()
          .having((s) => s.balance, 'balance', Decimal.fromInt(777)),
      isA<PortfolioState>().having((s) => s.sort, 'sort', HoldingsSort.symbol),
    ],
  );

  test(
      'repository streams update the bloc and repeated starts replace listeners',
      () async {
    final bloc = PortfolioBloc(repository);
    final states = <PortfolioState>[];
    final subscription = bloc.stream.listen(states.add);

    bloc.add(const PortfolioStarted());
    await bloc.stream.first;
    await repository.placeOrder(
      symbol: 'RELIANCE',
      side: OrderSide.buy,
      quantity: Decimal.one,
      price: Decimal.fromInt(100),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    bloc.add(const PortfolioStarted());
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(states.any((s) => s.holdings.isNotEmpty), isTrue);
    expect(states.any((s) => s.balance < Decimal.fromInt(1000000)), isTrue);
    await subscription.cancel();
    await bloc.close();
  });

  test('close cancels both repository subscriptions', () async {
    final bloc = PortfolioBloc(repository);
    bloc.add(const PortfolioStarted());
    await bloc.stream.first;
    await bloc.close();
    await repository.resetWallet();
    expect(bloc.isClosed, isTrue);
  });
}

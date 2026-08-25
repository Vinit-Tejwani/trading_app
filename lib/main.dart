import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'l10n/app_localizations.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/bloc/settings_bloc.dart';
import 'features/home/presentation/pages/home_shell_page.dart';
import 'features/holdings/data/portfolio_repository.dart';
import 'features/holdings/presentation/bloc/portfolio_bloc.dart';
import 'features/market_data/data/mock_market_feed.dart';
import 'features/market_data/presentation/bloc/market_bloc.dart';
import 'features/watchlist/data/watchlist_repository.dart';
import 'features/watchlist/presentation/bloc/watchlist_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorage.init();
  runApp(TradingApp(storage: storage));
}

class TradingApp extends StatelessWidget {
  final LocalStorage storage;
  const TradingApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final marketBloc = MarketBloc()..add(const MarketStarted());
    final persistedTickRate = storage.readTickRate();
    if (persistedTickRate != null) {
      marketBloc.add(MarketTickRateChanged(persistedTickRate));
    }
    final watchlistRepo = WatchlistRepository(storage);
    final portfolioRepo = PortfolioRepository(storage);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MockMarketFeed>.value(
            value: MockMarketFeed.instance),
        RepositoryProvider<WatchlistRepository>.value(value: watchlistRepo),
        RepositoryProvider<PortfolioRepository>.value(value: portfolioRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(create: (_) => SettingsBloc(storage)),
          BlocProvider<MarketBloc>.value(value: marketBloc),
          BlocProvider<WatchlistBloc>(
            create: (_) =>
                WatchlistBloc(watchlistRepo)..add(const WatchlistsLoaded()),
          ),
          BlocProvider<PortfolioBloc>(
            create: (_) =>
                PortfolioBloc(portfolioRepo)..add(const PortfolioStarted()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settings) {
            return MaterialApp(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settings.themeMode,
              home: const HomeShellPage(),
            );
          },
        ),
      ),
    );
  }
}

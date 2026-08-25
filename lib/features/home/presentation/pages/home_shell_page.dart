import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/shared/widgets/trading_header.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../holdings/presentation/pages/holdings_page.dart';
import '../../../market_data/domain/entities/stock.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';
import '../../../market_data/presentation/pages/market_overview_page.dart';
import '../../../order/presentation/pages/buy_sell_ticket_page.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../../watchlist/presentation/pages/watchlists_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int index = 1;
  late final PageController controller = PageController(initialPage: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void go(int i) {
    setState(() => index = i);
    controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[
      WatchlistsPageWithHeader(),
      MarketOverviewPage(),
      QuickTradePage(),
      HoldingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageView(
          controller: controller,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (i) => setState(() => index = i),
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.view_list_outlined),
            selectedIcon: const Icon(Icons.view_list_rounded),
            label: AppLocalizations.of(context).watchlist,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart_rounded),
            label: AppLocalizations.of(context).markets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz_rounded),
            label: AppLocalizations.of(context).trade,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: AppLocalizations.of(context).portfolio,
          ),
        ],
      ),
    );
  }
}

class QuickTradePage extends StatefulWidget {
  const QuickTradePage({super.key});

  @override
  State<QuickTradePage> createState() => _QuickTradePageState();
}

class _QuickTradePageState extends State<QuickTradePage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final symbols = AppConstants.stockSeeds.map((s) => s.symbol).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).tradeDesk,
                        style: AppTextStyles.headline,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).marketOrdersLiveLtp,
                        style: AppTextStyles.symbolSub,
                      ),
                    ],
                  ),
                ),
                LiveBadge(),
                IconButton(
                  tooltip: AppLocalizations.of(context).orderHistory,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryPage(),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => query = v.trim().toUpperCase()),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: AppLocalizations.of(context).searchStockToTrade,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (a, b) =>
                  a.quotesBySymbol.length != b.quotesBySymbol.length,
              builder: (context, state) {
                final quotes = state.quotesBySymbol.values.toList();
                final gainers =
                    quotes.where((q) => q.tick.change > Decimal.zero).length;
                final losers =
                    quotes.where((q) => q.tick.change < Decimal.zero).length;
                return _DeskSummary(
                  live: quotes.length,
                  gainers: gainers,
                  losers: losers,
                );
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: symbols.length,
            itemBuilder: (context, i) {
              final symbol = symbols[i];
              return BlocSelector<MarketBloc, MarketState, Quote?>(
                selector: (s) => s.quote(symbol),
                builder: (context, quote) {
                  if (quote == null) return const SizedBox.shrink();
                  if (query.isNotEmpty &&
                      !quote.stock.symbol.contains(query) &&
                      !quote.stock.name.toUpperCase().contains(query)) {
                    return const SizedBox.shrink();
                  }
                  final up = quote.tick.change >= Decimal.zero;
                  final color = up ? AppColors.positive : AppColors.negative;
                  return RepaintBoundary(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      decoration: BoxDecoration(
                        color: AppColors.card(context),
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider(context)),
                          left: BorderSide(color: color, width: 2),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BuySellTicketPage(symbol: symbol),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(13, 12, 10, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(symbol, style: AppTextStyles.symbol),
                                    const SizedBox(height: 3),
                                    Text(
                                      AppLocalizations.of(context)
                                          .nseEquityNamed(quote.stock.name),
                                      style: AppTextStyles.symbolSub,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.price(quote.tick.price),
                                    style: AppTextStyles.priceMedium,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    Formatters.signedPercent(
                                        quote.tick.changePercent),
                                    style: AppTextStyles.change
                                        .copyWith(color: color),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(66, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BuySellTicketPage(symbol: symbol),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).tradeAction,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _DeskSummary extends StatelessWidget {
  final int live;
  final int gainers;
  final int losers;

  const _DeskSummary(
      {required this.live, required this.gainers, required this.losers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardElevated(context), AppColors.card(context)],
        ),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DeskMetric(
              AppLocalizations.of(context).live,
              '$live/10',
              AppColors.accent,
            ),
          ),
          Expanded(
            child: _DeskMetric(
              AppLocalizations.of(context).gainers,
              '$gainers',
              AppColors.positive,
            ),
          ),
          Expanded(
            child: _DeskMetric(
              AppLocalizations.of(context).losers,
              '$losers',
              AppColors.negative,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DeskMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.priceSmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.label.copyWith(fontSize: 8)),
          ],
        ),
      ],
    );
  }
}

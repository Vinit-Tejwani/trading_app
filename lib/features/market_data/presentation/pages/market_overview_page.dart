import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/market_data/domain/entities/stock.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../../../home/presentation/bloc/settings_bloc.dart';
import '../../../holdings/data/portfolio_repository.dart';
import '../../../order/presentation/pages/buy_sell_ticket_page.dart';
import '../bloc/market_bloc.dart';
import '../widgets/quote_row.dart';

class MarketOverviewPage extends StatefulWidget {
  const MarketOverviewPage({super.key});

  @override
  State<MarketOverviewPage> createState() => _MarketOverviewPageState();
}

class _MarketOverviewPageState extends State<MarketOverviewPage> {
  MarketFilter filter = MarketFilter.all;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final symbols = AppConstants.stockSeeds.map((e) => e.symbol).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: TradingHeader(
            title: AppLocalizations.of(context).marketOverviewTitle,
            subtitle: AppLocalizations.of(context).marketOverviewSubtitle,
            actions: [
              LiveBadge(),
              const SizedBox(width: 4),
              IconButton(
                tooltip: AppLocalizations.of(context).marketSettings,
                onPressed: () => _showSettings(context),
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
            child: BlocBuilder<MarketBloc, MarketState>(
              buildWhen: (a, b) => a.quotesBySymbol != b.quotesBySymbol,
              builder: (context, state) {
                final quotes = state.quotesBySymbol.values.toList();
                return _MarketPulse(quotes: quotes);
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                TextField(
                  onChanged: (v) =>
                      setState(() => query = v.trim().toUpperCase()),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText:
                        AppLocalizations.of(context).searchSymbolOrCompany,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Filter(
                        AppLocalizations.of(context).all,
                        filter == MarketFilter.all,
                        () => setState(() => filter = MarketFilter.all)),
                    const SizedBox(width: 8),
                    _Filter(
                        AppLocalizations.of(context).gainers,
                        filter == MarketFilter.gainers,
                        () => setState(() => filter = MarketFilter.gainers)),
                    const SizedBox(width: 8),
                    _Filter(
                        AppLocalizations.of(context).losers,
                        filter == MarketFilter.losers,
                        () => setState(() => filter = MarketFilter.losers)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).symbol,
                        style: AppTextStyles.label,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        AppLocalizations.of(context).trend,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.label,
                      ),
                    ),
                    SizedBox(
                      width: 138,
                      child: Text(
                        AppLocalizations.of(context).ltpChange,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: AppColors.divider(context)),
              ],
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
                selector: (state) => state.quote(symbol),
                builder: (context, quote) {
                  if (quote == null) return const SizedBox.shrink();
                  final isUp = quote.tick.change > Decimal.zero;
                  final isDown = quote.tick.change < Decimal.zero;
                  final matchesQuery = query.isEmpty ||
                      quote.stock.symbol.contains(query) ||
                      quote.stock.name.toUpperCase().contains(query);
                  final matchesFilter = filter == MarketFilter.all ||
                      (filter == MarketFilter.gainers && isUp) ||
                      (filter == MarketFilter.losers && isDown);
                  if (!matchesQuery || !matchesFilter) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: QuoteRow(
                      quote: quote,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              BuySellTicketPage(symbol: quote.stock.symbol),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _MarketPulse extends StatelessWidget {
  final List<Quote> quotes;
  const _MarketPulse({required this.quotes});

  @override
  Widget build(BuildContext context) {
    final gainers = quotes.where((q) => q.tick.change > Decimal.zero).length;
    final losers = quotes.where((q) => q.tick.change < Decimal.zero).length;
    final sorted = [...quotes]
      ..sort((a, b) => b.tick.changePercent.compareTo(a.tick.changePercent));
    final leader = sorted.isEmpty ? null : sorted.first;
    final leaderColor = leader == null || leader.tick.change >= Decimal.zero
        ? AppColors.positive
        : AppColors.negative;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cardElevated(context), AppColors.card(context)],
        ),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).marketPulse,
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).liveMarket,
                      style: AppTextStyles.priceLarge,
                    ),
                  ],
                ),
              ),
              if (leader != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context).topMover,
                      style: AppTextStyles.label.copyWith(fontSize: 8),
                    ),
                    const SizedBox(height: 3),
                    Text(leader.stock.symbol,
                        style:
                            AppTextStyles.symbol.copyWith(color: leaderColor)),
                    Text(Formatters.signedPercent(leader.tick.changePercent),
                        style:
                            AppTextStyles.change.copyWith(color: leaderColor)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PulseMetric(
                  AppLocalizations.of(context).instruments,
                  '${quotes.length}/10',
                  AppColors.accent,
                ),
              ),
              Expanded(
                child: _PulseMetric(
                  AppLocalizations.of(context).gainers,
                  '$gainers',
                  AppColors.positive,
                ),
              ),
              Expanded(
                child: _PulseMetric(
                  AppLocalizations.of(context).losers,
                  '$losers',
                  AppColors.negative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _PulseMetric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: AppTextStyles.priceSmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.label.copyWith(fontSize: 7)),
          ]),
        ],
      );
}

class _Filter extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Filter(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: .12)
                : AppColors.card(context),
            border: Border.all(
                color: selected
                    ? AppColors.accent.withValues(alpha: .45)
                    : AppColors.outline(context)),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(label,
              style: AppTextStyles.label.copyWith(
                  fontSize: 9,
                  color: selected
                      ? AppColors.accent
                      : AppColors.textSecondary(context))),
        ),
      );
}

void _showSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<SettingsBloc>(),
      child: const _MarketSettingsSheet(),
    ),
  );
}

class _MarketSettingsSheet extends StatelessWidget {
  const _MarketSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card(context),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.divider(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context).marketSettingsTitle,
                  style: AppTextStyles.headline,
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).marketSettingsDescription,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: 18),
                Text(
                  AppLocalizations.of(context).tickRate,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [1000, 500, 200, 100].map((ms) {
                    return ChoiceChip(
                      label: Text(
                        ms >= 1000
                            ? AppLocalizations.of(context).seconds(ms ~/ 1000)
                            : AppLocalizations.of(context).milliseconds(ms),
                      ),
                      selected: state.tickRateMs == ms,
                      onSelected: (_) {
                        context
                            .read<SettingsBloc>()
                            .add(SettingsTickRateChanged(ms));
                        context
                            .read<MarketBloc>()
                            .add(MarketTickRateChanged(ms));
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).theme,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(AppLocalizations.of(context).dark),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(AppLocalizations.of(context).light),
                    ),
                  ],
                  selected: {
                    state.themeMode == ThemeMode.light
                        ? ThemeMode.light
                        : ThemeMode.dark
                  },
                  onSelectionChanged: (v) => context
                      .read<SettingsBloc>()
                      .add(SettingsThemeModeChanged(v.first)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(AppLocalizations.of(context).resetDemoAccount),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(dialogContext)
                                .resetDemoAccountTitle,
                          ),
                          content: Text(
                            AppLocalizations.of(dialogContext)
                                .resetDemoAccountDescription,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(
                                AppLocalizations.of(dialogContext).cancel,
                              ),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(
                                AppLocalizations.of(dialogContext).reset,
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        await context.read<PortfolioRepository>().resetWallet();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

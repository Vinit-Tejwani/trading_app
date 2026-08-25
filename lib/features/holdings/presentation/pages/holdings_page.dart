import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/enum.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';
import '../../../order/presentation/pages/buy_sell_ticket_page.dart';
import '../../../order/presentation/pages/order_history_page.dart';
import '../../domain/entities/holding.dart' as entity;
import '../bloc/portfolio_bloc.dart';
import '../widgets/holding_row.dart';
import '../widgets/portfolio_summary_card.dart';

class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, portfolio) {
        if (portfolio.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (portfolio.holdings.isEmpty) {
          return Column(
            children: [
              TradingHeader(
                title: AppLocalizations.of(context).portfolio,
                subtitle: AppLocalizations.of(context).noOpenPositions,
                actions: [
                  IconButton(
                    tooltip: AppLocalizations.of(context).orderHistory,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OrderHistoryPage(),
                      ),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined),
                  ),
                ],
              ),
              Expanded(
                child: EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: AppLocalizations.of(context).noHoldings,
                  message: AppLocalizations.of(context).noHoldingsMessage,
                ),
              ),
            ],
          );
        }

        final symbols = portfolio.holdings.map((h) => h.symbol).toSet();
        return BlocBuilder<MarketBloc, MarketState>(
          buildWhen: (previous, current) => symbols
              .any((symbol) => previous.quote(symbol) != current.quote(symbol)),
          builder: (context, market) {
            final rows = portfolio.holdings.map((holding) {
              final quote = market.quote(holding.symbol);
              return entity.HoldingRow(
                holding: holding,
                ltp: quote?.tick.price ?? holding.avgCost,
                previousLtp: quote?.tick.previousPrice ?? holding.avgCost,
              );
            }).toList();

            final summary = entity.HoldingsSummary.fromRows(rows);
            final sorted = [...rows]..sort(_comparator(portfolio.sort));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TradingHeader(
                    title: AppLocalizations.of(context).portfolio,
                    subtitle: portfolio.holdings.length == 1
                        ? AppLocalizations.of(context).openPosition(1)
                        : AppLocalizations.of(context)
                            .openPositions(portfolio.holdings.length),
                    actions: [
                      IconButton(
                        tooltip: AppLocalizations.of(context).orderHistory,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrderHistoryPage(),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        PortfolioSummaryCard(
                          summary: summary,
                          positionCount: portfolio.holdings.length,
                        ),
                        const SizedBox(height: 10),
                        _SortRow(
                          current: portfolio.sort,
                          onChanged: (sort) => context
                              .read<PortfolioBloc>()
                              .add(HoldingsSortChanged(sort)),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final row = sorted[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: HoldingRow(
                          key: ValueKey(row.holding.symbol),
                          holding: row.holding,
                          ltp: row.ltp,
                          previousLtp: row.previousLtp,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BuySellTicketPage(
                                symbol: row.holding.symbol,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            );
          },
        );
      },
    );
  }

  int Function(entity.HoldingRow, entity.HoldingRow) _comparator(
    HoldingsSort sort,
  ) {
    switch (sort) {
      case HoldingsSort.pnlDesc:
        return (a, b) => b.pnl.compareTo(a.pnl);
      case HoldingsSort.symbol:
        return (a, b) => a.holding.symbol.compareTo(b.holding.symbol);
      case HoldingsSort.currentValueDesc:
        return (a, b) => b.currentValue.compareTo(a.currentValue);
    }
  }
}

class _SortRow extends StatelessWidget {
  final HoldingsSort current;
  final ValueChanged<HoldingsSort> onChanged;

  const _SortRow({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: HoldingsSort.values.map((sort) {
        final selected = current == sort;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () => onChanged(sort),
              borderRadius: BorderRadius.circular(5),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: .12)
                      : AppColors.card(context),
                  border: Border.all(
                    color: selected
                        ? AppColors.accent.withValues(alpha: .35)
                        : AppColors.outline(context),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  _label(context, sort),
                  style: AppTextStyles.label.copyWith(
                    fontSize: 8,
                    color: selected
                        ? AppColors.accent
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(BuildContext context, HoldingsSort sort) {
    final l10n = AppLocalizations.of(context);
    switch (sort) {
      case HoldingsSort.pnlDesc:
        return l10n.pAndL;
      case HoldingsSort.symbol:
        return l10n.symbol;
      case HoldingsSort.currentValueDesc:
        return l10n.value;
    }
  }
}

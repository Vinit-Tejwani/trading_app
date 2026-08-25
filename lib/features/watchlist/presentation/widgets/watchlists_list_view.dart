import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';

import '../../../market_data/domain/entities/stock.dart';
import '../../domain/entities/watchlist.dart';
import 'watchlist_detail_page.dart';

class WatchlistsListView extends StatelessWidget {
  final List<Watchlist> watchlists;

  const WatchlistsListView({super.key, required this.watchlists});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: watchlists.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final watchlist = watchlists[index];
        return Material(
          color: AppColors.card(context),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WatchlistDetailPage(watchlistId: watchlist.id),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: BlocSelector<MarketBloc, MarketState, List<Quote>>(
                selector: (state) => watchlist.symbols
                    .map(state.quote)
                    .whereType<Quote>()
                    .toList(),
                builder: (context, quotes) {
                  final up =
                      quotes.where((q) => q.tick.change >= Decimal.zero).length;
                  final preview = quotes.take(2).toList();
                  return Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: .10),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: .25),
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.view_list_rounded,
                          color: AppColors.accent,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              watchlist.name.toUpperCase(),
                              style: AppTextStyles.symbol,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).instrumentSummary(
                                watchlist.symbols.length,
                                watchlist.symbols.length == 1 ? '' : 'S',
                                up,
                                up == 1 ? '' : 'S',
                              ),
                              style: AppTextStyles.label.copyWith(fontSize: 8),
                            ),
                            if (preview.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Wrap(
                                spacing: 7,
                                children: preview.map((q) {
                                  final color = q.tick.change >= Decimal.zero
                                      ? AppColors.positive
                                      : AppColors.negative;
                                  return Text(
                                    AppLocalizations.of(context).quotePreview(
                                      q.stock.symbol,
                                      Formatters.signedPercent(
                                          q.tick.changePercent),
                                    ),
                                    style: AppTextStyles.change.copyWith(
                                      fontSize: 9,
                                      color: color,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted(context),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

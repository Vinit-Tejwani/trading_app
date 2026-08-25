import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';
import '../../../market_data/presentation/widgets/quote_row.dart';

Future<String?> showStockPickerSheet(
  BuildContext context, {
  List<String> alreadyAdded = const [],
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => BlocProvider.value(
      value: context.read<MarketBloc>(),
      child: _StockPickerSheet(alreadyAdded: alreadyAdded),
    ),
  );
}

class _StockPickerSheet extends StatelessWidget {
  final List<String> alreadyAdded;
  const _StockPickerSheet({required this.alreadyAdded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, state) {
        final quotes = state.quotesBySymbol.values.toList()
          ..sort((a, b) => a.stock.symbol.compareTo(b.stock.symbol));
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: media.size.height * 0.8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      AppLocalizations.of(context).pickAStock,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: quotes.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) {
                        final q = quotes[i];
                        final added = alreadyAdded.contains(q.stock.symbol);
                        return Opacity(
                          opacity: added ? 0.45 : 1.0,
                          child: IgnorePointer(
                            ignoring: added,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                QuoteRow(
                                  quote: q,
                                  dense: true,
                                  onTap: () =>
                                      Navigator.of(context).pop(q.stock.symbol),
                                ),
                                if (added)
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(right: AppSpacing.lg),
                                    child: Icon(Icons.check_circle_rounded,
                                        size: 20),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

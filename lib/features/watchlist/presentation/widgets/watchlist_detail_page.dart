import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';
import '../../../market_data/presentation/widgets/quote_row.dart';
import '../../../order/presentation/pages/buy_sell_ticket_page.dart';
import '../../../stock_picker/presentation/widgets/stock_picker_sheet.dart';
import '../bloc/watchlist_bloc.dart';

class WatchlistDetailPage extends StatelessWidget {
  final String watchlistId;

  const WatchlistDetailPage({
    super.key,
    required this.watchlistId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final matches =
            state.watchlists.where((w) => w.id == watchlistId).toList();

        if (matches.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context).watchlistNotFound),
            ),
          );
        }

        final watchlist = matches.first;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                TradingHeader(
                  title: watchlist.name,
                  subtitle: watchlist.symbols.length == 1
                      ? AppLocalizations.of(context).instrumentCountSingular
                      : AppLocalizations.of(context)
                          .instrumentCount(watchlist.symbols.length),
                  actions: [
                    IconButton(
                      tooltip: AppLocalizations.of(context).rename,
                      onPressed: () => _promptRename(
                        context,
                        watchlist.id,
                        watchlist.name,
                      ),
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                    ),
                    IconButton(
                      tooltip: AppLocalizations.of(context).deleteWatchlist,
                      onPressed: () => _confirmDelete(
                        context,
                        watchlist.id,
                        watchlist.name,
                      ),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.negative,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: watchlist.symbols.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: AppLocalizations.of(context).noStocks,
                          message: AppLocalizations.of(context).noStocksMessage,
                          action: FilledButton.icon(
                            onPressed: () => _showPicker(
                              context,
                              watchlist.id,
                              watchlist.symbols,
                            ),
                            icon: const Icon(Icons.add),
                            label: Text(AppLocalizations.of(context).addStocks),
                          ),
                        )
                      : _StockList(
                          watchlistId: watchlist.id,
                          symbols: watchlist.symbols,
                        ),
                ),
                if (watchlist.symbols.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showPicker(
                          context,
                          watchlist.id,
                          watchlist.symbols,
                        ),
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context).addInstrument),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _showPicker(
    BuildContext context,
    String id,
    List<String> current,
  ) async {
    final selected = await showStockPickerSheet(
      context,
      alreadyAdded: current,
    );

    if (selected != null && context.mounted) {
      context.read<WatchlistBloc>().add(
            SymbolAddedToWatchlist(
              id,
              selected,
            ),
          );
    }
  }

  static Future<void> _promptRename(
    BuildContext context,
    String id,
    String current,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameWatchlistDialog(
        currentName: current,
      ),
    );

    if (!context.mounted) {
      return;
    }

    final trimmedName = name?.trim();

    if (trimmedName != null && trimmedName.isNotEmpty) {
      context.read<WatchlistBloc>().add(
            WatchlistRenamed(
              id,
              trimmedName,
            ),
          );
    }
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppLocalizations.of(ctx).deleteWatchlistTitle(name),
        ),
        content: Text(
          AppLocalizations.of(ctx).deleteWatchlistMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.negative,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(ctx).delete),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      context.read<WatchlistBloc>().add(
            WatchlistDeleted(id),
          );

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _RenameWatchlistDialog extends StatefulWidget {
  final String currentName;

  const _RenameWatchlistDialog({
    required this.currentName,
  });

  @override
  State<_RenameWatchlistDialog> createState() => _RenameWatchlistDialogState();
}

class _RenameWatchlistDialogState extends State<_RenameWatchlistDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.currentName,
    );

    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop();
  }

  void _save() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).renameWatchlist),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).name,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    );
  }
}

class _StockList extends StatelessWidget {
  final String watchlistId;
  final List<String> symbols;

  const _StockList({
    required this.watchlistId,
    required this.symbols,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketBloc, MarketState>(
      buildWhen: (previous, current) => symbols.any(
        (symbol) => previous.quote(symbol) != current.quote(symbol),
      ),
      builder: (context, market) {
        return ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            8,
          ),
          buildDefaultDragHandles: false,
          itemCount: symbols.length,
          onReorder: (oldIndex, newIndex) {
            context.read<WatchlistBloc>().add(
                  SymbolsReordered(
                    watchlistId,
                    oldIndex,
                    newIndex,
                  ),
                );
          },
          itemBuilder: (context, index) {
            final symbol = symbols[index];
            final quote = market.quote(symbol);

            return Padding(
              key: ValueKey('$watchlistId-$symbol'),
              padding: const EdgeInsets.only(
                bottom: 1,
              ),
              child: Dismissible(
                key: ValueKey(
                  'dismiss-$watchlistId-$symbol',
                ),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.negative.withValues(
                    alpha: .18,
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(
                    right: 20,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.negative,
                  ),
                ),
                onDismissed: (_) {
                  context.read<WatchlistBloc>().add(
                        SymbolRemovedFromWatchlist(
                          watchlistId,
                          symbol,
                        ),
                      );
                },
                child: Stack(
                  children: [
                    quote == null
                        ? Container(
                            height: 72,
                            color: AppColors.card(context),
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              symbol,
                              style: AppTextStyles.symbol,
                            ),
                          )
                        : QuoteRow(
                            quote: quote,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BuySellTicketPage(
                                  symbol: symbol,
                                ),
                              ),
                            ),
                          ),
                    Positioned(
                      right: 4,
                      top: 0,
                      bottom: 0,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 18,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../bloc/watchlist_bloc.dart';
import '../widgets/watchlists_list_view.dart';

class WatchlistsPage extends StatelessWidget {
  const WatchlistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.watchlists.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.view_list_outlined,
                    size: 46,
                    color: AppColors.textMuted(context),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppLocalizations.of(context).noWatchlists,
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context).createListMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => promptCreate(context),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context).createWatchlist),
                  ),
                ],
              ),
            ),
          );
        }

        return WatchlistsListView(
          watchlists: state.watchlists,
        );
      },
    );
  }

  static Future<void> promptCreate(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateWatchlistDialog(),
    );

    if (!context.mounted) return;

    final trimmedName = name?.trim();

    if (trimmedName != null && trimmedName.isNotEmpty) {
      context.read<WatchlistBloc>().add(
            WatchlistCreated(trimmedName),
          );
    }
  }
}

class _CreateWatchlistDialog extends StatefulWidget {
  const _CreateWatchlistDialog();

  @override
  State<_CreateWatchlistDialog> createState() => _CreateWatchlistDialogState();
}

class _CreateWatchlistDialogState extends State<_CreateWatchlistDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: AppLocalizations.of(context).defaultWatchlistName,
    );

    // Put the cursor at the end of the default text.
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
    // Remove focus before closing the dialog.
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop();
  }

  void _create() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      return;
    }

    // Remove focus before closing the dialog.
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).newWatchlist),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _create(),
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
          onPressed: _create,
          child: Text(AppLocalizations.of(context).create),
        ),
      ],
    );
  }
}

class WatchlistsPageWithHeader extends StatelessWidget {
  const WatchlistsPageWithHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TradingHeader(
          title: AppLocalizations.of(context).watchlists,
          subtitle: AppLocalizations.of(context).trackFavouriteInstruments,
          actions: [
            LiveBadge(),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => WatchlistsPage.promptCreate(context),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const Expanded(
          child: WatchlistsPage(),
        ),
      ],
    );
  }
}

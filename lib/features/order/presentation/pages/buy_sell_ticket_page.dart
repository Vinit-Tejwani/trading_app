import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/decimal_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../../../holdings/data/portfolio_repository.dart';
import '../../../holdings/domain/entities/holding.dart';
import '../../../market_data/domain/entities/stock.dart';
import '../../../market_data/presentation/bloc/market_bloc.dart';
import '../bloc/order_bloc.dart';
import 'order_confirmation_page.dart';

class BuySellTicketPage extends StatelessWidget {
  final String symbol;

  const BuySellTicketPage({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    // Resolve inherited dependencies before entering the provider factory.
    // Provider factories are one-time lifecycle callbacks and must not listen
    // to inherited widgets such as Localizations.
    final portfolio = context.read<PortfolioRepository>();
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => OrderBloc(
        portfolio,
        l10n: l10n,
      )..add(OrderInitialized(symbol)),
      child: _TicketView(symbol: symbol),
    );
  }
}

class _TicketView extends StatefulWidget {
  final String symbol;

  const _TicketView({required this.symbol});

  @override
  State<_TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<_TicketView> {
  final qty = TextEditingController(text: '1');

  @override
  void dispose() {
    qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketBloc, MarketState>(
      listenWhen: (previous, current) =>
          previous.quote(widget.symbol) != current.quote(widget.symbol),
      listener: (context, market) {
        final quote = market.quote(widget.symbol);
        if (quote != null) {
          context.read<OrderBloc>().add(OrderPriceRefreshed(quote.tick.price));
        }
      },
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          final order = state.lastOrder;
          if (order != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OrderConfirmationPage(order: order),
              ),
            );
          }
        },
        builder: (context, state) {
          final draft = state.draft;
          if (draft == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final isBuy = draft.side == OrderSide.buy;
          final accent = isBuy ? AppColors.accentStrong : AppColors.negative;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).orderTicket,
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                AppLocalizations.of(context)
                                    .marketOrderNseEquities,
                                style: AppTextStyles.symbolSub,
                              ),
                            ],
                          ),
                        ),
                        LiveBadge(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _QuoteHeader(symbol: widget.symbol),
                    const SizedBox(height: 12),
                    _SideSelector(state: state),
                    const SizedBox(height: 12),
                    _Quantity(
                      controller: qty,
                      onChanged: (value) => context.read<OrderBloc>().add(
                          OrderQuantityChanged(DecimalUtils.tryParse(value))),
                    ),
                    const SizedBox(height: 8),
                    _Availability(state: state),
                    const SizedBox(height: 12),
                    _Summary(state: state),
                    if (state.error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.negative.withValues(alpha: .10),
                          border: Border.all(
                            color: AppColors.negative.withValues(alpha: .30),
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.negative,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.negative,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor:
                            isBuy ? AppColors.accentInk : Colors.white,
                        minimumSize: const Size.fromHeight(54),
                      ),
                      onPressed: state.submitting
                          ? null
                          : () => context
                              .read<OrderBloc>()
                              .add(const OrderSubmitted()),
                      child: state.submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isBuy
                                  ? AppLocalizations.of(context)
                                      .buySymbol(draft.symbol)
                                  : AppLocalizations.of(context)
                                      .sellSymbol(draft.symbol),
                              style: AppTextStyles.button.copyWith(
                                color:
                                    isBuy ? AppColors.accentInk : Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context).orderExecutesAtLatestPrice,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.symbolSub,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuoteHeader extends StatelessWidget {
  final String symbol;

  const _QuoteHeader({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketBloc, MarketState, Quote?>(
      selector: (state) => state.quote(symbol),
      builder: (context, quote) {
        if (quote == null) return const SizedBox.shrink();
        final color = quote.tick.change >= Decimal.zero
            ? AppColors.positive
            : AppColors.negative;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.cardElevated(context),
                AppColors.card(context)
              ],
            ),
            border: Border.all(color: AppColors.outline(context)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(symbol, style: AppTextStyles.headline),
                        const SizedBox(height: 3),
                        Text(
                          AppLocalizations.of(context)
                              .nseEquityNamed(quote.stock.name),
                          style: AppTextStyles.symbolSub,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context).market,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.price(quote.tick.price),
                    style: AppTextStyles.priceHero,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context).quoteChangeSummary(
                      Formatters.signed(quote.tick.change),
                      Formatters.signedPercent(quote.tick.changePercent),
                    ),
                    style: AppTextStyles.change.copyWith(color: color),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SideSelector extends StatelessWidget {
  final OrderState state;

  const _SideSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final buy = state.draft?.side == OrderSide.buy;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Side(
              label: AppLocalizations.of(context).buy,
              selected: buy,
              color: AppColors.accentStrong,
              onTap: () => context
                  .read<OrderBloc>()
                  .add(const OrderSideToggled(OrderSide.buy)),
            ),
          ),
          Expanded(
            child: _Side(
              label: AppLocalizations.of(context).sell,
              selected: !buy,
              color: AppColors.negative,
              onTap: () => context
                  .read<OrderBloc>()
                  .add(const OrderSideToggled(OrderSide.sell)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Side({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .18) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: selected ? color : AppColors.textSecondary(context),
          ),
        ),
      ),
    );
  }
}

class _Quantity extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _Quantity({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).quantity,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Step(Icons.remove, () => _change(-1)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: AppTextStyles.priceLarge,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).quantityHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Step(Icons.add, () => _change(1)),
            ],
          ),
        ],
      ),
    );
  }

  void _change(int delta) {
    final current = DecimalUtils.tryParse(controller.text);
    final next = current + Decimal.fromInt(delta);
    final value = next < Decimal.one ? Decimal.one : next;
    controller.text = value.toString();
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    onChanged(controller.text);
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Step(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.accent.withValues(alpha: .08),
      ),
      icon: Icon(icon, color: AppColors.accent),
    );
  }
}

class _Availability extends StatelessWidget {
  final OrderState state;

  const _Availability({required this.state});

  @override
  Widget build(BuildContext context) {
    final draft = state.draft!;
    final portfolio = context.read<PortfolioRepository>();
    if (draft.side == OrderSide.buy) {
      return StreamBuilder<Decimal>(
        stream: portfolio.balanceStream,
        initialData: portfolio.balance,
        builder: (_, snapshot) {
          final balance = snapshot.data ?? portfolio.balance;
          return Text(
            AppLocalizations.of(context)
                .availableMarginAmount(Formatters.price(balance)),
            style: AppTextStyles.label.copyWith(
              color: draft.value > balance
                  ? AppColors.negative
                  : AppColors.textMuted(context),
              fontSize: 8,
            ),
          );
        },
      );
    }

    return StreamBuilder<List<Holding>>(
      stream: portfolio.holdingsStream,
      initialData: portfolio.holdings,
      builder: (_, snapshot) {
        final holdings = snapshot.data ?? portfolio.holdings;
        final matching =
            holdings.where((h) => h.symbol == draft.symbol).toList();
        final quantity =
            matching.isEmpty ? Decimal.zero : matching.first.quantity;
        return Text(
          AppLocalizations.of(context)
              .availableHolding(Formatters.quantity(quantity)),
          style: AppTextStyles.label.copyWith(
            color: draft.quantity > quantity
                ? AppColors.negative
                : AppColors.textMuted(context),
            fontSize: 8,
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  final OrderState state;

  const _Summary({required this.state});

  @override
  Widget build(BuildContext context) {
    final draft = state.draft!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        border: Border.all(
          color: AppColors.outline(context),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _row(
            context,
            AppLocalizations.of(context).ltp,
            Formatters.price(draft.price),
          ),
          const SizedBox(height: 9),
          _row(
            context,
            AppLocalizations.of(context).quantity,
            Formatters.quantity(draft.quantity),
          ),
          Divider(
            color: AppColors.divider(context),
            height: 18,
          ),
          _row(
            context,
            AppLocalizations.of(context).orderValue,
            Formatters.price(draft.value),
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool strong = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 8,
          ),
        ),
        Text(
          value,
          style: (strong ? AppTextStyles.priceLarge : AppTextStyles.priceSmall)
              .copyWith(
            color: strong ? AppColors.accent : AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

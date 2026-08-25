import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/trading_header.dart';
import '../../../holdings/data/portfolio_repository.dart';
import '../../../holdings/domain/entities/holding.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<PortfolioRepository>();
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Order>>(
          stream: repository.ordersStream,
          initialData: repository.orders,
          builder: (context, snapshot) {
            final orders = snapshot.data ?? const <Order>[];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TradingHeader(
                    title: AppLocalizations.of(context).orderHistory,
                    subtitle: orders.length == 1
                        ? AppLocalizations.of(context).executedOrder(1)
                        : AppLocalizations.of(context)
                            .executedOrders(orders.length),
                    actions: [
                      IconButton(
                        tooltip: AppLocalizations.of(context).close,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: _BalanceCard(balance: repository.balance),
                  ),
                ),
                if (orders.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: AppLocalizations.of(context).noOrders,
                      message: AppLocalizations.of(context)
                          .executedMarketOrdersAppearHere,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: _OrderTile(order: orders[index]),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final Decimal balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardElevated(context), AppColors.card(context)],
        ),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).availableMargin,
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).persistedDemoWallet,
                  style: AppTextStyles.symbolSub,
                ),
              ],
            ),
          ),
          Text(Formatters.price(balance), style: AppTextStyles.priceMedium),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final color = isBuy ? AppColors.positive : AppColors.negative;
    return RepaintBoundary(
      child: Material(
        color: AppColors.card(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  isBuy ? Icons.south_west_rounded : Icons.north_east_rounded,
                  color: color,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(order.symbol, style: AppTextStyles.symbol),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBuy
                                ? AppLocalizations.of(context).buy
                                : AppLocalizations.of(context).sell,
                            style: AppTextStyles.label
                                .copyWith(color: color, fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).sharesAtPrice(
                        Formatters.quantity(order.quantity),
                        _time(order.timestamp),
                      ),
                      style: AppTextStyles.symbolSub,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Formatters.price(order.value),
                      style: AppTextStyles.priceSmall),
                  const SizedBox(height: 3),
                  Text(
                    AppLocalizations.of(context)
                        .atPrice(Formatters.price(order.price)),
                    style: AppTextStyles.symbolSub,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _time(DateTime time) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(time.day)}/${two(time.month)} ${two(time.hour)}:${two(time.minute)}';
  }
}

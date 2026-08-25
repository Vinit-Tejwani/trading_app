import 'package:flutter/material.dart';
import 'package:trading_app/core/constants/enum.dart';
import 'package:trading_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../holdings/domain/entities/holding.dart';

class OrderConfirmationPage extends StatelessWidget {
  final Order order;
  const OrderConfirmationPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuy = order.side == OrderSide.buy;
    final accent = isBuy ? AppColors.positive : AppColors.negative;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
        title: Text(AppLocalizations.of(context).orderConfirmed),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.horizontalPadding(context),
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Icon(
                        isBuy
                            ? Icons.north_east_rounded
                            : Icons.south_east_rounded,
                        size: 42,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      isBuy
                          ? AppLocalizations.of(context).buyOrderPlaced
                          : AppLocalizations.of(context).sellOrderPlaced,
                      style: AppTextStyles.headline
                          .copyWith(color: theme.textTheme.bodyLarge!.color),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).sharesOfAt(
                        Formatters.quantity(order.quantity),
                        order.symbol,
                        Formatters.price(order.price),
                      ),
                      style: AppTextStyles.body
                          .copyWith(color: theme.textTheme.bodySmall?.color),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          AppLocalizations.of(context).orderId,
                          _shortId(order.id),
                          theme,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _detailRow(
                          AppLocalizations.of(context).side,
                          isBuy
                              ? AppLocalizations.of(context).buy
                              : AppLocalizations.of(context).sell,
                          theme,
                          valueColor: accent,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _detailRow(
                          AppLocalizations.of(context).symbolLabel,
                          order.symbol,
                          theme,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _detailRow(
                          AppLocalizations.of(context).quantityLabel,
                          Formatters.quantity(order.quantity),
                          theme,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _detailRow(
                          AppLocalizations.of(context).price,
                          Formatters.price(order.price),
                          theme,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(height: 1, color: theme.dividerColor),
                        const SizedBox(height: AppSpacing.md),
                        _detailRow(
                          AppLocalizations.of(context).orderValueLabel,
                          Formatters.price(order.value),
                          theme,
                          valueStyle: AppTextStyles.priceMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? AppColors.cardElevated(context)
                          : const Color(0xFFF3F3F5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 15, color: theme.textTheme.bodySmall?.color),
                        const SizedBox(width: AppSpacing.sm),
                        Text(_formatTime(order.timestamp),
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Text(
                      AppLocalizations.of(context).done,
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).placeAnotherOrder),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme,
      {Color? valueColor, TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.symbolSub
                .copyWith(color: theme.textTheme.bodySmall!.color)),
        Text(value,
            style: valueStyle ??
                AppTextStyles.symbol.copyWith(
                  color: valueColor ?? theme.textTheme.bodyLarge!.color,
                  fontSize: 14,
                )),
      ],
    );
  }

  String _shortId(String id) =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}

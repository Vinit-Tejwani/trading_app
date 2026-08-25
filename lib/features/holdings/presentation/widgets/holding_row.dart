import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/decimal_utils.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/animated_price_text.dart';
import '../../../../shared/widgets/flash_highlight.dart';
import '../../domain/entities/holding.dart';

class HoldingRow extends StatelessWidget {
  final Holding holding;
  final Decimal ltp;
  final Decimal previousLtp;
  final VoidCallback? onTap;

  const HoldingRow({
    super.key,
    required this.holding,
    required this.ltp,
    required this.previousLtp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = holding.quantity * ltp;
    final pnl = value - holding.invested;
    final pct = holding.invested == Decimal.zero
        ? Decimal.zero
        : DecimalUtils.divide(pnl, holding.invested, scale: 8);
    final pnlColor =
        pnl >= Decimal.zero ? AppColors.positive : AppColors.negative;
    final tickUp = ltp > previousLtp;
    final tickDown = ltp < previousLtp;

    return RepaintBoundary(
      child: Material(
        color: AppColors.card(context),
        child: InkWell(
          onTap: onTap,
          child: FlashPulse(
            isUp: tickUp,
            isDown: tickDown,
            signal: ltp.toString(),
            builder: (_, opacity) => Container(
              decoration: BoxDecoration(
                color: Color.lerp(
                  AppColors.card(context),
                  pnlColor.withValues(alpha: .08),
                  opacity,
                ),
                border: Border(
                  left: BorderSide(color: pnlColor, width: 2),
                  bottom: BorderSide(color: AppColors.divider(context)),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(holding.symbol, style: AppTextStyles.symbol),
                            const SizedBox(height: 3),
                            Text(
                              AppLocalizations.of(context)
                                  .holdingQuantityAverage(
                                Formatters.price(holding.avgCost),
                                Formatters.quantity(holding.quantity),
                              ),
                              style: AppTextStyles.symbolSub,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).ltp,
                            style: AppTextStyles.label.copyWith(fontSize: 8),
                          ),
                          const SizedBox(height: 2),
                          AnimatedPriceText(
                            price: ltp,
                            style: AppTextStyles.priceMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _stat(
                          AppLocalizations.of(context).currentValue,
                          Formatters.price(value),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).pAndL,
                            style: AppTextStyles.label.copyWith(fontSize: 8),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppLocalizations.of(context).pnlSummary(
                              Formatters.signed(pnl),
                              Formatters.signedPercent(pct),
                            ),
                            style: AppTextStyles.priceSmall
                                .copyWith(color: pnlColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 8)),
        const SizedBox(height: 3),
        Text(value, style: AppTextStyles.priceSmall),
      ],
    );
  }
}

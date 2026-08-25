import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/animated_price_text.dart';
import '../../../../shared/widgets/flash_highlight.dart';
import '../../../../shared/widgets/mini_sparkline.dart';
import '../../domain/entities/stock.dart';

class QuoteRow extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onTap;
  final bool dense;
  final bool showName;
  const QuoteRow(
      {super.key,
      required this.quote,
      this.onTap,
      this.dense = false,
      this.showName = true});

  @override
  Widget build(BuildContext context) {
    final tick = quote.tick;
    final up = tick.isUp || tick.change > Decimal.zero;
    final down = tick.isDown || tick.change < Decimal.zero;
    final color = up
        ? AppColors.positive
        : down
            ? AppColors.negative
            : AppColors.textSecondary(context);
    return RepaintBoundary(
      child: Material(
        color: AppColors.card(context),
        child: InkWell(
          onTap: onTap,
          child: FlashPulse(
            isUp: up,
            isDown: down,
            signal: tick.timestamp,
            builder: (context, opacity) => Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: color, width: 2)),
                color: Color.lerp(AppColors.card(context),
                    color.withValues(alpha: .10), opacity),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 14, vertical: dense ? 10 : 12),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        tick.symbol,
                        style: AppTextStyles.symbol.copyWith(
                          fontSize: dense ? 14 : 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        showName
                            ? AppLocalizations.of(context)
                                .nseEquityNamed(quote.stock.name)
                            : AppLocalizations.of(context).nseEquity,
                        style: AppTextStyles.symbolSub,
                      ),
                    ])),
                MiniSparkline(value: tick.price.toDouble(), up: up, down: down),
                const SizedBox(width: 12),
                Container(
                  width: dense ? 124 : 138,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  color: color.withValues(alpha: .20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedPriceText(
                            price: tick.price,
                            style: AppTextStyles.priceMedium.copyWith(
                                color: color, fontSize: dense ? 14 : 15)),
                        const SizedBox(height: 3),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                  up
                                      ? Icons.arrow_drop_up
                                      : down
                                          ? Icons.arrow_drop_down
                                          : Icons.remove,
                                  color: color,
                                  size: 16),
                              Text(Formatters.signedPercent(tick.changePercent),
                                  style: AppTextStyles.change
                                      .copyWith(color: color))
                            ]),
                      ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

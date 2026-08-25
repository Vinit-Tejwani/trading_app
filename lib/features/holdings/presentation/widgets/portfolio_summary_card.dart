import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/holding.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final HoldingsSummary summary;
  final int positionCount;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
    required this.positionCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = summary.totalPnl > Decimal.zero
        ? AppColors.positive
        : summary.totalPnl < Decimal.zero
            ? AppColors.negative
            : AppColors.textSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cardElevated(context), AppColors.card(context)],
        ),
        border: Border.all(color: AppColors.outline(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).portfolioValue,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 5),
          Text(Formatters.price(summary.currentValue),
              style: AppTextStyles.priceHero),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                summary.totalPnl >= Decimal.zero
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                AppLocalizations.of(context).pnlSummary(
                  Formatters.signed(summary.totalPnl),
                  Formatters.signedPercent(summary.totalPnlPercent),
                ),
                style: AppTextStyles.change.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.divider(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _stat(
                AppLocalizations.of(context).invested,
                Formatters.price(summary.totalInvested),
              )),
              Expanded(
                child: _stat(
                  AppLocalizations.of(context).positions,
                  '$positionCount',
                ),
              ),
              Expanded(
                child: _stat(
                  AppLocalizations.of(context).pAndL,
                  Formatters.signed(summary.totalPnl),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 8)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.priceSmall),
      ],
    );
  }
}

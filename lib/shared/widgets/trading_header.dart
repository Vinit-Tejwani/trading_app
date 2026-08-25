import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class TradingHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  const TradingHeader(
      {super.key, required this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(7)),
              child: const Icon(Icons.candlestick_chart_rounded,
                  color: AppColors.accentInk, size: 20)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted(context),
                          letterSpacing: .5))
              ])),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  final String? text;
  const LiveBadge({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final displayText = text ?? AppLocalizations.of(context).live;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: .10),
        border: Border.all(color: AppColors.accent.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: .9,
            ),
          ),
        ],
      ),
    );
  }
}

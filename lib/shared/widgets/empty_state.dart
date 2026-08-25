import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: theme.dividerColor),
              ),
              alignment: Alignment.center,
              child:
                  Icon(icon, size: 28, color: theme.textTheme.bodySmall?.color),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.symbol.copyWith(
                fontSize: 16,
                color: theme.textTheme.bodyLarge!.color,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.body
                  .copyWith(color: theme.textTheme.bodySmall?.color),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline,
              size: 18, color: theme.colorScheme.onErrorContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: theme.colorScheme.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

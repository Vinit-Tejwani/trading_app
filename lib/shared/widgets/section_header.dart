import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool showLivePulse;

  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.showLivePulse = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headline.copyWith(
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  if (showLivePulse) ...[
                    const _LivePulse(),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      subtitle,
                      style: AppTextStyles.body
                          .copyWith(color: theme.textTheme.bodySmall!.color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _LivePulse extends StatefulWidget {
  const _LivePulse();
  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.positive,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

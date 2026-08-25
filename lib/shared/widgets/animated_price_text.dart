import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class AnimatedPriceText extends StatelessWidget {
  final Decimal price;
  final TextStyle? style;
  final Duration duration;

  const AnimatedPriceText({
    super.key,
    required this.price,
    this.style,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: Text(
        Formatters.price(price),
        key: ValueKey(price.toString()),
        style: style,
      ),
    );
  }
}

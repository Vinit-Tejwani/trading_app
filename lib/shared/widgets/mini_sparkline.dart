import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MiniSparkline extends StatelessWidget {
  final double value;
  final bool up;
  final bool down;
  const MiniSparkline(
      {super.key, required this.value, required this.up, required this.down});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 84,
        height: 38,
        child: CustomPaint(
          painter:
              _SparkPainter(value, up, down, AppColors.textSecondary(context)),
        ));
  }
}

class _SparkPainter extends CustomPainter {
  final double value;
  final bool up;
  final bool down;
  final Color neutralColor;

  _SparkPainter(
    this.value,
    this.up,
    this.down,
    this.neutralColor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final color = up
        ? AppColors.positive
        : down
            ? AppColors.negative
            : neutralColor;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final seed = (value * 100).round() % 17;

    final path = Path();

    for (int i = 0; i < 7; i++) {
      final x = i * size.width / 6;

      final wave = math.sin((i + seed) * .9) * 5;

      final trend = up
          ? -i * 2.2
          : down
              ? i * 2.2
              : 0;

      final y = size.height / 2 + wave + trend;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) {
    return old.value != value ||
        old.up != up ||
        old.down != down ||
        old.neutralColor != neutralColor;
  }
}

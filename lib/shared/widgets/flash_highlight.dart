import 'package:flutter/material.dart';

/// Drives a 0→1→0 pulse whenever [signal] changes (while up/down is true).
/// Exposes opacity to [builder] rather than painting an overlay itself —
/// callers pulse a small accent element (a bar, a dot) instead of tinting
/// the whole row, which stays readable at high tick rates.
class FlashPulse extends StatefulWidget {
  final bool isUp;
  final bool isDown;
  final Object signal;
  final Duration duration;
  final Widget Function(BuildContext context, double opacity) builder;

  const FlashPulse({
    super.key,
    required this.isUp,
    required this.isDown,
    required this.signal,
    required this.builder,
    this.duration = const Duration(milliseconds: 550),
  });

  @override
  State<FlashPulse> createState() => _FlashPulseState();
}

class _FlashPulseState extends State<FlashPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 85),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant FlashPulse old) {
    super.didUpdateWidget(old);
    if ((widget.isUp || widget.isDown) && old.signal != widget.signal) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => widget.builder(context, _opacity.value),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';

/// Animated progress bar (XP inside the current level, HP…).
/// Animates smoothly from the previous value whenever [value] changes.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 12,
    this.shimmer = false,
  });

  /// 0.0 → 1.0
  final double value;
  final Color color;
  final double height;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, animated, _) {
            Widget fill = FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animated,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.7), color],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            );
            if (shimmer) {
              fill = fill
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2400.ms, delay: 1200.ms);
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: track),
                fill,
              ],
            );
          },
        ),
      ),
    );
  }
}

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) =>
      ProgressBar(value: ratio, color: AppColors.xp, shimmer: true);
}

class HpBar extends StatelessWidget {
  const HpBar({super.key, required this.hp});

  final int hp;

  @override
  Widget build(BuildContext context) => ProgressBar(
    value: hp / 100,
    height: 8,
    color: hp <= 25 ? AppColors.hpLow : AppColors.hp,
  );
}

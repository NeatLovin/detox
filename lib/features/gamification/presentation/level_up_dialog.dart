import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_theme.dart';

/// True when [next] is a real level-up of the same player (not the first load).
bool isLevelUp({required int? previousLevel, required int nextLevel}) =>
    previousLevel != null && nextLevel > previousLevel;

Future<void> showLevelUpDialog(BuildContext context, int level) => showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'level-up',
  barrierColor: Colors.black87,
  transitionDuration: const Duration(milliseconds: 200),
  pageBuilder: (context, _, _) => _LevelUpView(level: level),
);

class _LevelUpView extends StatelessWidget {
  const _LevelUpView({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final random = math.Random(level);
    const bits = ['✨', '⭐', '🔥', '💪', '🎉'];

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Falling sparkles.
          for (var i = 0; i < 18; i++)
            Positioned(
              left: random.nextDouble() * size.width,
              top: -40,
              child: Text(bits[i % bits.length], style: const TextStyle(fontSize: 26))
                  .animate(delay: (random.nextInt(600)).ms)
                  .moveY(
                    begin: 0,
                    end: size.height * (0.6 + random.nextDouble() * 0.4),
                    duration: (1600 + random.nextInt(900)).ms,
                    curve: Curves.easeIn,
                  )
                  .fadeOut(delay: 1200.ms, duration: 600.ms),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.levelUpTitle, style: theme.textTheme.titleLarge)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.5),
                const SizedBox(height: 12),
                Container(
                  width: 160,
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.xp, AppColors.seed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.seed.withValues(alpha: 0.6),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: Text(
                    '$level',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    )
                    .then()
                    .shimmer(duration: 1200.ms),
                const SizedBox(height: 20),
                Text(
                  l10n.levelUpBody(level),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.levelUpContinue),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

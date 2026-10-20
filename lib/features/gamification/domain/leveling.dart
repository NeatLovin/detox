import 'dart:math' as math;

/// Total XP needed to reach [level]: 50·L·(L−1). L2 = 100, L3 = 300, L4 = 600…
/// Mirrors public.xp_for_level in SQL.
int xpForLevel(int level) {
  final l = math.max(level, 1);
  return 50 * l * (l - 1);
}

/// Level reached with [xp]: floor((1 + sqrt(1 + xp / 12.5)) / 2).
/// Mirrors public.level_for_xp in SQL (same formula, same boundary guards).
int levelForXp(int xp) {
  final x = math.max(xp, 0);
  var level = ((1 + math.sqrt(1 + x / 12.5)) / 2).floor();
  if (xpForLevel(level + 1) <= x) {
    level += 1;
  } else if (xpForLevel(level) > x) {
    level -= 1;
  }
  return math.max(level, 1);
}

/// Progress inside the current level, for the XP bar.
class LevelProgress {
  const LevelProgress({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
  });

  factory LevelProgress.fromXp(int xp) {
    final level = levelForXp(xp);
    final floor = xpForLevel(level);
    final next = xpForLevel(level + 1);
    return LevelProgress(
      level: level,
      xpIntoLevel: math.max(xp, 0) - floor,
      xpForNextLevel: next - floor,
    );
  }

  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;

  /// 0.0 → 1.0
  double get ratio =>
      xpForNextLevel == 0 ? 0 : (xpIntoLevel / xpForNextLevel).clamp(0.0, 1.0);
}

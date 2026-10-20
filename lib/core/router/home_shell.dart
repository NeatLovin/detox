import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/gamification/presentation/engagement_providers.dart';
import '../../features/quests/presentation/quest_providers.dart';
import '../l10n/l10n.dart';
import '../utils/day.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late final AppLifecycleListener _lifecycle;
  String _day = dayKey(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Day-scoped data (pledge, quests) must roll over when the app comes back
    // to the foreground on a new day.
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  void _onResume() {
    final today = dayKey(DateTime.now());
    if (today == _day) return;
    _day = today;
    ref.invalidate(pledgedTodayProvider);
    ref.invalidate(questLogsProvider);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  StatefulNavigationShell get shell => widget.shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l10n.navQuests,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            selectedIcon: const Icon(Icons.groups),
            label: l10n.navSquad,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}

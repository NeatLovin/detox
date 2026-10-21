import 'package:flutter/material.dart';

import '../../../../core/errors/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/feed_reaction.dart';

/// Reaction chips under a feed event, plus a button to react. The tap is
/// shown at once and confirmed by the realtime stream.
class ReactionBar extends StatefulWidget {
  const ReactionBar({
    super.key,
    required this.summary,
    required this.allowed,
    this.onReact,
  });

  final ReactionSummary summary;
  final List<String> allowed;

  /// Null for the player's own events: counts only, no reacting.
  final Future<void> Function(String emoji)? onReact;

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  ReactionSummary? _optimistic;
  bool _busy = false;

  @override
  void didUpdateWidget(ReactionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary != widget.summary) _optimistic = null;
  }

  Future<void> _react(String emoji) async {
    final onReact = widget.onReact;
    if (onReact == null || _busy) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _busy = true;
      _optimistic = (_optimistic ?? widget.summary).toggle(emoji);
    });
    try {
      await onReact(emoji);
    } catch (error) {
      if (mounted) setState(() => _optimistic = null);
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, error))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pick() async {
    final emoji = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              for (final emoji in widget.allowed)
                IconButton(
                  iconSize: 36,
                  onPressed: () => Navigator.pop(context, emoji),
                  icon: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
            ],
          ),
        ),
      ),
    );
    if (emoji != null) await _react(emoji);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final summary = _optimistic ?? widget.summary;
    final canReact = widget.onReact != null;
    if (summary.isEmpty && !canReact) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final MapEntry(key: emoji, value: count) in summary.ordered)
          _Chip(
            label: '$emoji $count',
            selected: summary.mine == emoji,
            onTap: canReact && widget.allowed.contains(emoji)
                ? () => _react(emoji)
                : null,
          ),
        if (canReact)
          IconButton(
            tooltip: l10n.feedReact,
            iconSize: 18,
            style: IconButton.styleFrom(
              minimumSize: const Size(36, 32),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.add_reaction_outlined),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primary.withValues(alpha: 0.25)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? scheme.primary : Colors.transparent,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/profile_rules.dart';

class EmojiGrid extends StatelessWidget {
  const EmojiGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GridView.count(
      crossAxisCount: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: [
        for (final emoji in ProfileRules.avatarEmojis)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelected(emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: emoji == selected
                    ? primary.withValues(alpha: 0.3)
                    : null,
                border: Border.all(
                  color: emoji == selected ? primary : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
      ],
    );
  }
}

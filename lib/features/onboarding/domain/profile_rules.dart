/// Mirrors the CHECK constraint on profiles.username.
abstract final class ProfileRules {
  static final _username = RegExp(r'^[A-Za-z0-9_.-]{3,20}$');

  static bool isValidUsername(String value) => _username.hasMatch(value.trim());

  static const avatarEmojis = <String>[
    '😎',
    '🦊',
    '🐻',
    '🐸',
    '🐺',
    '🦁',
    '🐯',
    '🐼',
    '🐵',
    '🦉',
    '🐙',
    '🦈',
    '🐲',
    '🦄',
    '🤖',
    '👾',
    '👻',
    '💀',
    '🥷',
    '🧙',
    '🦸',
    '🧛',
    '🧟',
    '🤠',
    '🔥',
    '⚡',
    '🌊',
    '🌙',
    '🍀',
    '💎',
    '🎯',
    '🚀',
  ];
}

import 'dart:math';

class AnonymousNameGenerator {
  static final List<String> _adjectives = [
    'Brave', 'Strong', 'Hopeful', 'Resilient', 'Kind',
    'Courageous', 'Gentle', 'Peaceful', 'Bright', 'Wise',
    'Silent', 'Bold', 'Calm', 'Happy', 'Lucky',
    'Sweet', 'Noble', 'Pure', 'Free', 'True',
  ];

  static final List<String> _nouns = [
    'Butterfly', 'Phoenix', 'Warrior', 'Survivor', 'Star',
    'Moon', 'Sun', 'Ocean', 'Mountain', 'River',
    'Lotus', 'Rose', 'Tree', 'Bird', 'Lion',
    'Tiger', 'Wolf', 'Eagle', 'Dolphin', 'Owl',
  ];

  static final List<String> _avatars = [
    '🦋', '🌸', '🌺', '🌻', '🌼', '🌷', '🌹', '🏵️',
    '💮', '🪷', '🌿', '🍀', '🌾', '🌱', '🪴',
    '🦅', '🦉', '🦆', '🦢', '🕊️', '🦜', '🦩',
    '🐝', '🦄', '🐉', '🦋', '🐛', '🐌', '🦗',
    '🌙', '⭐', '✨', '💫', '☀️', '🌟', '🌠',
  ];

  static String generateName() {
    final random = Random();
    final adjective = _adjectives[random.nextInt(_adjectives.length)];
    final noun = _nouns[random.nextInt(_nouns.length)];
    return '$adjective $noun';
  }

  static String generateAvatar() {
    final random = Random();
    return _avatars[random.nextInt(_avatars.length)];
  }

  static Map<String, String> generateIdentity() {
    return {
      'name': generateName(),
      'avatar': generateAvatar(),
    };
  }
}
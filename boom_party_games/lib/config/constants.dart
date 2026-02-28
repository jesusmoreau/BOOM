class AppConstants {
  static const String appName = 'BOOM! Party Games';
  static const String appVersion = 'v1.0.0';
  static const String packageName = 'com.boom.partygames';

  // Player limits
  static const int minPlayers = 2;
  static const int maxPlayers = 10;

  // Word Bomb timer
  static const int wordBombTimerMin = 8;
  static const int wordBombTimerMax = 20;
  static const int wordBombDefaultLives = 3;

  // 3 en 5 timer
  static const int threeInFiveDefaultTimer = 5;

  // Taboo timer
  static const int tabooDefaultTimer = 60;

  // Sound Chain
  static const int soundChainMemorizeTime = 10;
  static const int soundChainEasyCount = 5;
  static const int soundChainHardCount = 10;

  // Splash
  static const int splashDurationMs = 1500;

  // Player emojis
  static const List<String> playerEmojis = [
    '😎', '🤪', '😂', '🤓', '😜', '🥳', '😈', '🤠', '👻', '🦊',
    '🐸', '🦄', '🐶', '🐱', '🦁', '🐵', '🐼', '🦋', '🌟', '🔥',
  ];

  // Explosion messages
  static const List<String> explosionMessages = [
    '¡La bomba explotó!',
    '¡BOOM! No fue suficiente rápido...',
    '¡Eso dolió!',
    '¡Volaste por los aires!',
    '¡Kaboom! Mejor suerte la próxima',
    '¡Se acabó el tiempo!',
    '¡Tic tac... BOOM!',
    '¡No sobreviviste esta ronda!',
    '¡La bomba no perdona!',
    '¡Hasta la vista, baby!',
  ];
}

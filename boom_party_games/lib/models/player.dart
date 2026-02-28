class Player {
  final String name;
  final String emoji;
  int lives;
  int score;
  bool isEliminated;

  Player({
    required this.name,
    required this.emoji,
    this.lives = 3,
    this.score = 0,
    this.isEliminated = false,
  });

  void loseLife() {
    lives--;
    if (lives <= 0) {
      isEliminated = true;
    }
  }

  void resetForNewGame({int startingLives = 3}) {
    lives = startingLives;
    score = 0;
    isEliminated = false;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'] as String,
        emoji: json['emoji'] as String,
      );
}

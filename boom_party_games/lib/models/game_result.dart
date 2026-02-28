import 'player.dart';

class GameResult {
  final Player loser;
  final String message;
  final String? penalty;

  const GameResult({
    required this.loser,
    required this.message,
    this.penalty,
  });
}

class ImpostorResult {
  final Player impostor;
  final String secretWord;
  final String category;
  final Map<Player, Player> votes;
  final bool groupWon;

  const ImpostorResult({
    required this.impostor,
    required this.secretWord,
    required this.category,
    required this.votes,
    required this.groupWon,
  });
}

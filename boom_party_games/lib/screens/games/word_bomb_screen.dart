import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/word_bomb_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/bomb_timer.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../utils/navigation_utils.dart';
import '../results/bomb_exploded_screen.dart';
import '../game_selector_screen.dart';

class WordBombScreen extends StatefulWidget {
  final List<Player> players;

  const WordBombScreen({super.key, required this.players});

  @override
  State<WordBombScreen> createState() => _WordBombScreenState();
}

class _WordBombScreenState extends State<WordBombScreen> {
  late List<Player> _activePlayers;
  int _currentPlayerIndex = 0;
  int _round = 1;
  Map<String, dynamic> _currentChallenge = {};
  bool _exploded = false;
  int _bombDuration = 0;
  Key _bombKey = UniqueKey();

  Player get _currentPlayer => _activePlayers[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _activePlayers = widget.players.map((p) {
      p.resetForNewGame();
      return p;
    }).toList();
    _startNewRound();
  }

  void _startNewRound() {
    setState(() {
      _exploded = false;
      _currentChallenge = randomFrom(wordBombChallenges);
      _bombDuration = randomBombTime();
      _bombKey = UniqueKey();
    });
  }

  void _onPass() {
    if (_exploded) return;
    AudioService().playCorrect();
    HapticService().lightTap();
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
      // Skip eliminated players
      while (_activePlayers[_currentPlayerIndex].isEliminated) {
        _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
      }
    });
  }

  void _onExplode() {
    if (_exploded) return;
    setState(() {
      _exploded = true;
    });

    final loser = _currentPlayer;
    loser.loseLife();

    Navigator.of(context).push(
      fadeRoute(BombExplodedScreen(
          loser: loser,
          onNextRound: () {
            Navigator.of(context).pop();
            // Check if game is over
            final alivePlayers =
                _activePlayers.where((p) => !p.isEliminated).toList();
            if (alivePlayers.length <= 1) {
              _showGameOver(alivePlayers.isNotEmpty ? alivePlayers.first : null);
            } else {
              _moveToNextAlivePlayer();
              _round++;
              _startNewRound();
            }
          },
          onChangeGame: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              smoothRoute(GameSelectorScreen(players: widget.players)),
            );
          },
        ),
      ),
    );
  }

  void _moveToNextAlivePlayer() {
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
    while (_activePlayers[_currentPlayerIndex].isEliminated) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
    }
  }

  void _showGameOver(Player? winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          winner != null ? '\u{1F3C6} GANADOR!' : 'Fin del juego',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (winner != null) ...[
              Text(
                '${winner.emoji} ${winner.name}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Es el ultimo en pie!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                smoothRoute(GameSelectorScreen(players: widget.players)),
              );
            },
            child: const Text(
              'VOLVER AL MENU',
              style: TextStyle(color: AppColors.accent, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _activePlayers = widget.players.map((p) {
                p.resetForNewGame();
                return p;
              }).toList();
              _currentPlayerIndex = 0;
              _round = 1;
              _startNewRound();
            },
            child: const Text(
              'JUGAR DE NUEVO',
              style: TextStyle(color: AppColors.success, fontSize: 16),
            ),
          ),
        ],
      ),
    );
    AudioService().playVictory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'Ronda $_round',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    List.generate(_currentPlayer.lives, (_) => '\u{2764}\u{FE0F}')
                        .join(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),

              const Spacer(),

              // Current player
              Text(
                '${_currentPlayer.emoji} ${_currentPlayer.name.toUpperCase()}',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 200.ms),

              const SizedBox(height: 24),

              // Challenge card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _currentChallenge['display'] ?? '',
                  style: AppTheme.gameDisplayStyle,
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Bomb
              if (!_exploded)
                BombTimer(
                  key: _bombKey,
                  durationSeconds: _bombDuration,
                  onExplode: _onExplode,
                ),

              const Spacer(),

              // Pass button
              if (!_exploded)
                AnimatedButton(
                  text: 'PASO \u{2713}',
                  color: AppColors.success,
                  onPressed: _onPass,
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

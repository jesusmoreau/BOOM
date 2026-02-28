import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../models/player.dart';
import '../models/game_config.dart';
import '../widgets/game_card.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../utils/navigation_utils.dart';
import 'games/word_bomb_screen.dart';
import 'games/impostor_screen.dart';
import 'games/three_in_five_screen.dart';
import 'games/sound_chain_screen.dart';
import 'games/taboo_screen.dart';
import 'games/truth_or_dare_screen.dart';

class GameSelectorScreen extends StatelessWidget {
  final List<Player> players;

  const GameSelectorScreen({super.key, required this.players});

  void _navigateToGame(BuildContext context, GameInfo game) {
    AudioService().playWhoosh();
    HapticService().lightTap();

    Widget screen;
    switch (game.type) {
      case GameType.wordBomb:
        screen = WordBombScreen(players: players);
        break;
      case GameType.impostor:
        screen = ImpostorScreen(players: players);
        break;
      case GameType.threeInFive:
        screen = ThreeInFiveScreen(players: players);
        break;
      case GameType.soundChain:
        screen = SoundChainScreen(players: players);
        break;
      case GameType.taboo:
        screen = TabooScreen(players: players);
        break;
      case GameType.truthOrDare:
        screen = TruthOrDareScreen(players: players);
        break;
    }

    Navigator.of(context).push(smoothRoute(screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textPrimary, size: 22),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Elige un juego',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              '${players.length} jugadores listos',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.success.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Player avatars stack
                      SizedBox(
                        width: 60,
                        height: 36,
                        child: Stack(
                          children: [
                            for (int i = 0;
                                i < players.length && i < 3;
                                i++)
                              Positioned(
                                left: i * 18.0,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cardBackground,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      players[i].emoji,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Game grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: GameInfo.allGames.length,
                    itemBuilder: (context, index) {
                      final game = GameInfo.allGames[index];
                      return GameCard(
                        gameInfo: game,
                        playerCount: players.length,
                        onTap: () => _navigateToGame(context, game),
                      )
                          .animate()
                          .fadeIn(
                            duration: 350.ms,
                            delay: Duration(milliseconds: 80 * index),
                          )
                          .slideY(
                            begin: 0.15,
                            end: 0,
                            duration: 350.ms,
                            delay: Duration(milliseconds: 80 * index),
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

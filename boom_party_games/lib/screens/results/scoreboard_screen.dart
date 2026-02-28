import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../widgets/animated_button.dart';

class ScoreboardScreen extends StatelessWidget {
  final List<Player> players;
  final VoidCallback onContinue;

  const ScoreboardScreen({
    super.key,
    required this.players,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.warning.withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('\u{1F3C6}', style: TextStyle(fontSize: 48))
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 8),
                Text(
                  'Marcador',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedPlayers.length,
                    itemBuilder: (context, index) {
                      final player = sortedPlayers[index];
                      final isFirst = index == 0;
                      final isTop3 = index < 3;
                      final medals = ['\u{1F947}', '\u{1F948}', '\u{1F949}'];

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isFirst
                              ? LinearGradient(
                                  colors: [
                                    AppColors.warning.withValues(alpha: 0.15),
                                    AppColors.warning.withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                          color: isFirst
                              ? null
                              : Colors.white.withValues(alpha: 0.04),
                          border: Border.all(
                            color: isFirst
                                ? AppColors.warning.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.06),
                            width: isFirst ? 1.5 : 1,
                          ),
                          boxShadow: isFirst
                              ? [
                                  BoxShadow(
                                    color: AppColors.warning
                                        .withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Position
                            SizedBox(
                              width: 32,
                              child: isTop3
                                  ? Text(medals[index],
                                      style: const TextStyle(fontSize: 22))
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Text(player.emoji,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isFirst
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: (isFirst
                                        ? AppColors.warning
                                        : AppColors.accent)
                                    .withValues(alpha: 0.15),
                              ),
                              child: Text(
                                '${player.score} pts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isFirst
                                      ? AppColors.warning
                                      : AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            duration: 250.ms,
                            delay: Duration(milliseconds: 80 * index),
                          ).slideX(
                            begin: 0.1,
                            end: 0,
                            duration: 250.ms,
                            delay: Duration(milliseconds: 80 * index),
                          );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'CONTINUAR',
                  gradient: AppColors.successGradient,
                  onPressed: onContinue,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

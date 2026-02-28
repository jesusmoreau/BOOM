import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/penalty_wheel.dart';
import '../../services/ads_service.dart';

class BombExplodedScreen extends StatefulWidget {
  final Player loser;
  final VoidCallback onNextRound;
  final VoidCallback onChangeGame;

  const BombExplodedScreen({
    super.key,
    required this.loser,
    required this.onNextRound,
    required this.onChangeGame,
  });

  @override
  State<BombExplodedScreen> createState() => _BombExplodedScreenState();
}

class _BombExplodedScreenState extends State<BombExplodedScreen> {
  bool _showPenalty = false;
  String? _penalty;

  @override
  void initState() {
    super.initState();
    _checkPenalties();
    AdsService().onRoundComplete();
  }

  Future<void> _checkPenalties() async {
    final prefs = await SharedPreferences.getInstance();
    final penaltiesEnabled = prefs.getBool('penaltiesEnabled') ?? true;
    if (penaltiesEnabled) {
      setState(() {
        _showPenalty = true;
        _penalty = randomFrom(penalties);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Explosion con glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        blurRadius: 120,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                  child: const Text('\u{1F4A5}',
                      style: TextStyle(fontSize: 120)),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .shake(duration: 500.ms, delay: 500.ms),

                const SizedBox(height: 20),

                // BOOM text con gradiente
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ).createShader(bounds),
                  child: Text(
                    'BOOM!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 52,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                  ),
                )
                    .animate()
                    .shake(duration: 600.ms)
                    .then()
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.03, 1.03),
                      duration: 300.ms,
                    ),

                const SizedBox(height: 16),

                Text(
                  '${widget.loser.emoji} ${widget.loser.name}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 6),

                Text(
                  randomExplosionMessage(),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 500.ms),

                if (_showPenalty && _penalty != null) ...[
                  const SizedBox(height: 24),
                  PenaltyDisplay(penalty: _penalty!)
                      .animate()
                      .fadeIn(delay: 800.ms)
                      .slideY(begin: 0.2, end: 0, delay: 800.ms),
                ],

                const Spacer(),

                AnimatedButton(
                  text: 'SIGUIENTE RONDA',
                  gradient: AppColors.successGradient,
                  onPressed: widget.onNextRound,
                ),
                const SizedBox(height: 12),
                AnimatedButton(
                  text: 'CAMBIAR JUEGO',
                  outlined: true,
                  gradient: AppColors.accentGradient,
                  onPressed: widget.onChangeGame,
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

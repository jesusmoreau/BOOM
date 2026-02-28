import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/truth_or_dare_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ads_service.dart';
import '../../utils/navigation_utils.dart';
import '../game_selector_screen.dart';

enum TruthOrDarePhase { choosing, showing }

class TruthOrDareScreen extends StatefulWidget {
  final List<Player> players;
  const TruthOrDareScreen({super.key, required this.players});

  @override
  State<TruthOrDareScreen> createState() => _TruthOrDareScreenState();
}

class _TruthOrDareScreenState extends State<TruthOrDareScreen> {
  TruthOrDarePhase _phase = TruthOrDarePhase.choosing;
  int _currentPlayerIndex = 0;
  int _intensity = 0; // 0=suave, 1=picante, 2=extremo
  bool _extremeUnlocked = false;
  String? _chosenType; // "verdad" or "reto"
  String _currentPrompt = '';

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _checkExtremeUnlock();
  }

  Future<void> _checkExtremeUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockTime = prefs.getInt('extremeUnlockTime') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    // Unlocked for 24 hours
    if (now - unlockTime < 24 * 60 * 60 * 1000) {
      setState(() => _extremeUnlocked = true);
    }
  }

  Future<void> _unlockExtreme() async {
    AdsService().showRewarded(onComplete: () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'extremeUnlockTime', DateTime.now().millisecondsSinceEpoch);
      if (mounted) {
        setState(() {
          _extremeUnlocked = true;
          _intensity = 2;
        });
      }
    });
  }

  void _chooseTruthOrDare(String type) {
    AudioService().playTap();
    HapticService().mediumTap();

    final intensityKeys = ['suave', 'picante', 'extremo'];
    final prompts = truthOrDareData[type]?[intensityKeys[_intensity]] ?? [];
    if (prompts.isEmpty) return;

    setState(() {
      _chosenType = type;
      _currentPrompt = randomFrom(prompts);
      _phase = TruthOrDarePhase.showing;
    });
  }

  void _onComplete(bool completed) {
    if (completed) {
      AudioService().playCorrect();
      HapticService().success();
      _currentPlayer.score++;
    } else {
      AudioService().playChicken();
      HapticService().wrong();
    }

    AdsService().onRoundComplete();

    setState(() {
      _currentPlayerIndex =
          (_currentPlayerIndex + 1) % widget.players.length;
      _phase = TruthOrDarePhase.choosing;
      _chosenType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == TruthOrDarePhase.showing) return _buildShowScreen();
    return _buildChooseScreen();
  }

  Widget _buildChooseScreen() {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verdad o Reto',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),

                const Spacer(),

                // Player
                Text(
                  _currentPlayer.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentPlayer.name.toUpperCase(),
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                const SizedBox(height: 32),

                // Truth or Dare buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _chooseTruthOrDare('verdad'),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: AppColors.accentGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('\u{1F914}',
                                  style: TextStyle(fontSize: 32)),
                              SizedBox(height: 4),
                              Text(
                                'VERDAD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _chooseTruthOrDare('reto'),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('\u{1F4AA}',
                                  style: TextStyle(fontSize: 32)),
                              SizedBox(height: 4),
                              Text(
                                'RETO',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Intensity selector
                Text(
                  'INTENSIDAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _intensityChip(0, '\u{1F7E2} Suave', AppColors.success),
                    const SizedBox(width: 8),
                    _intensityChip(1, '\u{1F7E1} Picante', AppColors.warning),
                    const SizedBox(width: 8),
                    _extremeUnlocked
                        ? _intensityChip(
                            2, '\u{1F534} Extremo', AppColors.primary)
                        : GestureDetector(
                            onTap: _unlockExtreme,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primary.withValues(alpha: 0.1),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '\u{1F534} \u{1F512}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.play_circle_outline,
                                      color: AppColors.primary, size: 16),
                                ],
                              ),
                            ),
                          ),
                  ],
                ),

                const Spacer(),

                AnimatedButton(
                  text: 'CAMBIAR JUEGO',
                  outlined: true,
                  gradient: AppColors.accentGradient,
                  height: 48,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      smoothRoute(GameSelectorScreen(players: widget.players)),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _intensityChip(int index, String label, Color color) {
    final isSelected = _intensity == index;
    return GestureDetector(
      onTap: () {
        HapticService().lightTap();
        setState(() => _intensity = index);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildShowScreen() {
    final isTruth = _chosenType == 'verdad';
    final color = isTruth ? AppColors.accent : AppColors.primary;
    final gradient = isTruth ? AppColors.accentGradient : AppColors.primaryGradient;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              color.withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          LinearGradient(colors: gradient).createShader(bounds),
                      child: Text(
                        isTruth ? 'VERDAD' : 'RETO',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Player
                Text(
                  '${_currentPlayer.emoji} ${_currentPlayer.name}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 24),

                // Prompt card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    _currentPrompt,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 300.ms),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{2713} CUMPLIO',
                        gradient: AppColors.successGradient,
                        height: 64,
                        onPressed: () => _onComplete(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{1F414} SE RAJO',
                        gradient: AppColors.warmGradient,
                        height: 64,
                        onPressed: () => _onComplete(false),
                      ),
                    ),
                  ],
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

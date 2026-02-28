import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/sound_chain_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/bomb_timer.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ads_service.dart';
import '../../utils/navigation_utils.dart';
import '../results/bomb_exploded_screen.dart';
import '../game_selector_screen.dart';

enum SoundChainPhase { setup, memorize, playing, roundResult }

class SoundChainScreen extends StatefulWidget {
  final List<Player> players;
  const SoundChainScreen({super.key, required this.players});

  @override
  State<SoundChainScreen> createState() => _SoundChainScreenState();
}

class _SoundChainScreenState extends State<SoundChainScreen> {
  SoundChainPhase _phase = SoundChainPhase.setup;
  int _difficulty = 1; // 0=easy(5), 1=normal(8), 2=hard(10)
  late List<Map<String, String>> _assignments;
  int _memorizeLeft = 10;
  Timer? _memorizeTimer;
  int _currentPlayerIndex = 0;
  int _currentNumber = 1;
  int _round = 1;
  int _bombDuration = 0;
  Key _bombKey = UniqueKey();
  bool _exploded = false;

  int get _soundCount => [5, 8, 10][_difficulty];
  int get _memorizeTime => [15, 10, 8][_difficulty];

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  void _startGame() {
    AudioService().playWhoosh();
    HapticService().mediumTap();
    _generateAssignments();
    setState(() {
      _phase = SoundChainPhase.memorize;
      _memorizeLeft = _memorizeTime;
    });
    _startMemorizeTimer();
  }

  void _generateAssignments() {
    final shuffled = List<Map<String, String>>.from(animalSounds)..shuffle(Random());
    _assignments = shuffled.take(_soundCount).toList();
  }

  void _startMemorizeTimer() {
    _memorizeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _memorizeLeft--;
      });

      if (_memorizeLeft <= 3 && _memorizeLeft > 0) {
        AudioService().playTimerBeep();
        HapticService().bombTick();
      }

      if (_memorizeLeft <= 0) {
        timer.cancel();
        _startPlayPhase();
      }
    });
  }

  void _startPlayPhase() {
    AudioService().playWhoosh();
    setState(() {
      _phase = SoundChainPhase.playing;
      _currentPlayerIndex = 0;
      _currentNumber = 1;
      _exploded = false;
      _bombDuration = randomBombTime();
      _bombKey = UniqueKey();
    });
  }

  void _onCorrect() {
    if (_exploded) return;
    AudioService().playCorrect();
    HapticService().lightTap();

    setState(() {
      _currentNumber++;
      if (_currentNumber > _soundCount) {
        _currentNumber = 1;
      }
      _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
    });
  }

  void _onFailed() {
    if (_exploded) return;
    _exploded = true;
    AudioService().playWrong();
    HapticService().explosion();

    final loser = _currentPlayer;
    loser.loseLife();

    Navigator.of(context).push(
      fadeRoute(BombExplodedScreen(
        loser: loser,
        onNextRound: () {
          Navigator.of(context).pop();
          AdsService().onRoundComplete();
          _round++;
          _generateAssignments();
          setState(() {
            _phase = SoundChainPhase.memorize;
            _memorizeLeft = _memorizeTime;
            _currentNumber = 1;
            _currentPlayerIndex = 0;
            _exploded = false;
          });
          _startMemorizeTimer();
        },
        onChangeGame: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
            smoothRoute(GameSelectorScreen(players: widget.players)),
          );
        },
      )),
    );
  }

  void _onBombExplode() {
    _onFailed();
  }

  @override
  void dispose() {
    _memorizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case SoundChainPhase.setup:
        return _buildSetupScreen();
      case SoundChainPhase.memorize:
        return _buildMemorizeScreen();
      case SoundChainPhase.playing:
        return _buildPlayScreen();
      case SoundChainPhase.roundResult:
        return const SizedBox();
    }
  }

  Widget _buildSetupScreen() {
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sound Chain',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),

                const Spacer(),

                const Text('\u{1F50A}', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),

                Text(
                  'Memoriza los sonidos\ny repitelos en orden!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Difficulty selector
                Text(
                  'DIFICULTAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: List.generate(3, (index) {
                      final labels = ['Facil (5)', 'Normal (8)', 'Dificil (10)'];
                      final isSelected = index == _difficulty;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _difficulty = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: AppColors.accentGradient,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                labels[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                AnimatedButton(
                  text: 'EMPEZAR',
                  gradient: AppColors.successGradient,
                  emoji: '\u{1F3AE}',
                  onPressed: _startGame,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemorizeScreen() {
    final timerColor = _memorizeLeft > 5
        ? AppColors.success
        : _memorizeLeft > 3
            ? AppColors.warning
            : AppColors.primary;

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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sound Chain',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: timerColor.withValues(alpha: 0.2),
                        border: Border.all(
                            color: timerColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '\u{23F1}\u{FE0F} ${_memorizeLeft}s',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: timerColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'MEMORIZA!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.warning,
                    letterSpacing: 2,
                  ),
                ).animate().shake(duration: 500.ms),

                const SizedBox(height: 12),

                // Sound assignments list
                Expanded(
                  child: ListView.builder(
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      final a = _assignments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha: 0.04),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    colors: AppColors.accentGradient),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${a['emoji']}',
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a['sound'] ?? '',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              a['animal'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                            duration: 200.ms,
                            delay: Duration(milliseconds: 50 * index),
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

  Widget _buildPlayScreen() {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sound Chain',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Ronda $_round',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Current player
                Text(
                  'Turno de:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentPlayer.emoji} ${_currentPlayer.name}',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(duration: 200.ms),

                const SizedBox(height: 32),

                // Number display
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.accentGradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_currentNumber',
                      style: AppTheme.timerStyle.copyWith(fontSize: 52),
                    ),
                  ),
                ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 16),

                Text(
                  '\u{2753}',
                  style: const TextStyle(fontSize: 48),
                ),

                const Spacer(),

                // Bomb
                if (!_exploded)
                  BombTimer(
                    key: _bombKey,
                    durationSeconds: _bombDuration,
                    onExplode: _onBombExplode,
                    showFuse: false,
                  ),

                const Spacer(),

                // Action buttons
                if (!_exploded)
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedButton(
                          text: '\u{2713} CORRECTO',
                          gradient: AppColors.successGradient,
                          height: 64,
                          onPressed: _onCorrect,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedButton(
                          text: '\u{2717} FALLO',
                          gradient: AppColors.primaryGradient,
                          height: 64,
                          onPressed: _onFailed,
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

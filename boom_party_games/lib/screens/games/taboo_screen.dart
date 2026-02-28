import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/taboo_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ads_service.dart';
import '../../utils/navigation_utils.dart';
import '../game_selector_screen.dart';

class TabooScreen extends StatefulWidget {
  final List<Player> players;
  const TabooScreen({super.key, required this.players});

  @override
  State<TabooScreen> createState() => _TabooScreenState();
}

class _TabooScreenState extends State<TabooScreen> {
  int _currentPlayerIndex = 0;
  int _timerSeconds = 60;
  int _secondsLeft = 60;
  Timer? _timer;
  bool _isPlaying = false;
  bool _roundOver = false;
  int _points = 0;
  int _skips = 0;
  int _taboos = 0;
  Map<String, dynamic> _currentWord = {};
  final List<int> _usedIndices = [];
  Key _wordKey = UniqueKey();

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _loadTimerSetting();
    _pickWord();
  }

  Future<void> _loadTimerSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final timerIndex = prefs.getInt('tabooTimer') ?? 1;
    setState(() {
      _timerSeconds = [30, 60, 90][timerIndex];
      _secondsLeft = _timerSeconds;
    });
  }

  void _pickWord() {
    if (_usedIndices.length >= tabooData.length) {
      _usedIndices.clear();
    }
    int index;
    do {
      index = randomIndex(tabooData.length);
    } while (_usedIndices.contains(index));
    _usedIndices.add(index);
    setState(() {
      _currentWord = tabooData[index];
      _wordKey = UniqueKey();
    });
  }

  void _startRound() {
    AudioService().playWhoosh();
    HapticService().mediumTap();
    setState(() {
      _isPlaying = true;
      _roundOver = false;
      _points = 0;
      _skips = 0;
      _taboos = 0;
      _secondsLeft = _timerSeconds;
    });
    _pickWord();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 5 && _secondsLeft > 0) {
        AudioService().playTimerBeep();
        HapticService().bombTick();
      }

      if (_secondsLeft <= 0) {
        timer.cancel();
        _endRound();
      }
    });
  }

  void _endRound() {
    _timer?.cancel();
    AudioService().playReveal();
    HapticService().explosion();
    AdsService().onRoundComplete();
    setState(() {
      _isPlaying = false;
      _roundOver = true;
    });
  }

  void _onCorrect() {
    if (!_isPlaying) return;
    AudioService().playCorrect();
    HapticService().success();
    setState(() {
      _points++;
    });
    _pickWord();
  }

  void _onSkip() {
    if (!_isPlaying) return;
    AudioService().playTap();
    HapticService().lightTap();
    setState(() {
      _skips++;
    });
    _pickWord();
  }

  void _onTaboo() {
    if (!_isPlaying) return;
    AudioService().playWrong();
    HapticService().wrong();
    setState(() {
      _taboos++;
      _points--;
    });
    _pickWord();
  }

  void _nextPlayer() {
    setState(() {
      _currentPlayerIndex =
          (_currentPlayerIndex + 1) % widget.players.length;
      _isPlaying = false;
      _roundOver = false;
      _secondsLeft = _timerSeconds;
    });
    _pickWord();
  }

  Color _timerColor() {
    if (_secondsLeft > 15) return AppColors.success;
    if (_secondsLeft > 5) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_roundOver) return _buildResultScreen();
    if (!_isPlaying) return _buildReadyScreen();
    return _buildPlayScreen();
  }

  Widget _buildReadyScreen() {
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
                      'Tabu Express',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),

                const Spacer(),

                const Text('\u{1F6AB}', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),

                Text(
                  'Turno de:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentPlayer.emoji} ${_currentPlayer.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                const SizedBox(height: 16),

                Text(
                  'Describe la palabra sin usar\nlas palabras prohibidas!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),
                Text(
                  'Timer: ${_timerSeconds}s',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),

                const Spacer(),

                AnimatedButton(
                  text: 'EMPEZAR',
                  gradient: AppColors.successGradient,
                  emoji: '\u{1F3AE}',
                  onPressed: _startRound,
                ),
                const SizedBox(height: 12),
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

  Widget _buildPlayScreen() {
    final word = _currentWord['word'] ?? '';
    final tabooWords = _currentWord['taboo'] as List<dynamic>? ?? [];

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
                // Header with timer and info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tabu Express',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          '${_currentPlayer.emoji} ${_currentPlayer.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Points
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.success.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            '$_points pts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _timerColor().withValues(alpha: 0.15),
                            border: Border.all(
                                color: _timerColor().withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${_secondsLeft}s',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _timerColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Word card
                Container(
                  key: _wordKey,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Main word
                      Text(
                        word.toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 16),

                      // Taboo words
                      ...tabooWords.map((taboo) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close_rounded,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  taboo.toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ).animate().fadeIn(duration: 150.ms),

                const Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{2713}',
                        gradient: AppColors.successGradient,
                        height: 64,
                        onPressed: _onCorrect,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{23ED}\u{FE0F} PASO',
                        color: AppColors.surface,
                        height: 64,
                        onPressed: _onSkip,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{2717} TABU',
                        gradient: AppColors.primaryGradient,
                        height: 64,
                        onPressed: _onTaboo,
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

  Widget _buildResultScreen() {
    final netPoints = _points;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              (netPoints > 0 ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.1),
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

                Text(
                  netPoints > 0 ? '\u{1F389}' : '\u{23F0}',
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 16),

                Text(
                  'Tiempo!',
                  style: Theme.of(context).textTheme.displayMedium,
                ),

                const SizedBox(height: 8),
                Text(
                  '${_currentPlayer.emoji} ${_currentPlayer.name}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 32),

                // Stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _statRow(
                          '\u{2705} Aciertos', '$_points', AppColors.success),
                      const SizedBox(height: 8),
                      _statRow(
                          '\u{23ED}\u{FE0F} Pasos', '$_skips', AppColors.textMuted),
                      const SizedBox(height: 8),
                      _statRow(
                          '\u{274C} Tabus', '$_taboos', AppColors.primary),
                      const SizedBox(height: 12),
                      Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      _statRow('Total', '$netPoints puntos',
                          netPoints > 0 ? AppColors.success : AppColors.primary),
                    ],
                  ),
                ),

                const Spacer(),

                AnimatedButton(
                  text: 'SIGUIENTE JUGADOR',
                  gradient: AppColors.successGradient,
                  onPressed: _nextPlayer,
                ),
                const SizedBox(height: 12),
                AnimatedButton(
                  text: 'CAMBIAR JUEGO',
                  outlined: true,
                  gradient: AppColors.accentGradient,
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

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

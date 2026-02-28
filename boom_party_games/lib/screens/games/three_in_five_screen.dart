import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/three_in_five_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ads_service.dart';
import '../../utils/navigation_utils.dart';
import '../game_selector_screen.dart';

class ThreeInFiveScreen extends StatefulWidget {
  final List<Player> players;

  const ThreeInFiveScreen({super.key, required this.players});

  @override
  State<ThreeInFiveScreen> createState() => _ThreeInFiveScreenState();
}

class _ThreeInFiveScreenState extends State<ThreeInFiveScreen> {
  int _currentPlayerIndex = 0;
  String _currentCategory = '';
  int _timerSeconds = 5;
  int _secondsLeft = 5;
  Timer? _timer;
  bool _timerRunning = false;
  bool _timerExpired = false;
  final List<String> _usedCategories = [];

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  @override
  void initState() {
    super.initState();
    _loadTimerSetting();
    _pickCategory();
  }

  Future<void> _loadTimerSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final timerIndex = prefs.getInt('threeInFiveTimer') ?? 1;
    setState(() {
      _timerSeconds = [3, 5, 7][timerIndex];
      _secondsLeft = _timerSeconds;
    });
  }

  void _pickCategory() {
    final available = threeInFiveCategories
        .where((c) => !_usedCategories.contains(c))
        .toList();
    if (available.isEmpty) {
      _usedCategories.clear();
      _currentCategory = randomFrom(threeInFiveCategories);
    } else {
      _currentCategory = randomFrom(available);
    }
    _usedCategories.add(_currentCategory);
  }

  void _startTimer() {
    if (_timerRunning) return;
    setState(() {
      _timerRunning = true;
      _timerExpired = false;
      _secondsLeft = _timerSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 3 && _secondsLeft > 0) {
        AudioService().playTimerBeep();
        HapticService().bombTick();
      }

      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() {
          _timerRunning = false;
          _timerExpired = true;
        });
        AudioService().playWrong();
        HapticService().explosion();
      }
    });
  }

  void _onResult(bool success) {
    _timer?.cancel();
    if (success) {
      AudioService().playCorrect();
      HapticService().success();
      _currentPlayer.score++;
    } else {
      AudioService().playWrong();
      HapticService().wrong();
    }

    AdsService().onRoundComplete();

    setState(() {
      _currentPlayerIndex =
          (_currentPlayerIndex + 1) % widget.players.length;
      _timerRunning = false;
      _timerExpired = false;
      _secondsLeft = _timerSeconds;
      _pickCategory();
    });
  }

  Color _timerColor() {
    if (_secondsLeft > 3) return AppColors.success;
    if (_secondsLeft > 1) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary),
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    '3 en 5',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '${_currentPlayer.emoji} ${_currentPlayer.name}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),

              const Spacer(),

              // Instruction
              Text(
                'Nombra 3...',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),

              const SizedBox(height: 16),

              // Category card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _currentCategory.toUpperCase(),
                  style: AppTheme.gameDisplayStyle,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 200.ms),

              const Spacer(),

              // Timer
              if (!_timerRunning && !_timerExpired)
                AnimatedButton(
                  text: 'EMPEZAR TIMER',
                  color: AppColors.accent,
                  emoji: '\u{23F1}\u{FE0F}',
                  onPressed: _startTimer,
                )
              else
                Text(
                  '$_secondsLeft',
                  style: AppTheme.timerStyle.copyWith(
                    fontSize: 72,
                    color: _timerColor(),
                  ),
                )
                    .animate(
                      target: _secondsLeft <= 1 ? 1 : 0,
                    )
                    .shake(duration: 300.ms),

              const Spacer(),

              // Result buttons
              if (_timerRunning || _timerExpired)
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{2713} LOGRO',
                        color: AppColors.success,
                        height: 64,
                        onPressed: () => _onResult(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedButton(
                        text: '\u{2717} FALLO',
                        color: AppColors.primary,
                        height: 64,
                        onPressed: () => _onResult(false),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Change game button
              AnimatedButton(
                text: 'CAMBIAR JUEGO',
                color: AppColors.surface,
                height: 48,
                onPressed: () {
                  _timer?.cancel();
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
    );
  }
}

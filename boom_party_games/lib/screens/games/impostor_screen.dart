import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../data/impostor_data.dart';
import '../../utils/random_utils.dart';
import '../../widgets/animated_button.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../services/ads_service.dart';
import '../../utils/navigation_utils.dart';
import '../results/vote_screen.dart';

enum ImpostorPhase { distributing, showingRole, clueRound, voting }

class ImpostorScreen extends StatefulWidget {
  final List<Player> players;

  const ImpostorScreen({super.key, required this.players});

  @override
  State<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends State<ImpostorScreen> {
  ImpostorPhase _phase = ImpostorPhase.distributing;
  int _currentPlayerIndex = 0;
  late Player _impostor;
  late String _category;
  late String _secretWord;
  bool _roleRevealed = false;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    // Pick random category and word
    final categories = impostorData.keys.toList();
    _category = randomFrom(categories);
    final words = impostorData[_category]!;
    _secretWord = randomFrom(words);

    // Pick random impostor
    _impostor = randomFrom(widget.players);

    setState(() {
      _phase = ImpostorPhase.distributing;
      _currentPlayerIndex = 0;
      _roleRevealed = false;
    });
  }

  Player get _currentPlayer => widget.players[_currentPlayerIndex];

  void _revealRole() {
    AudioService().playTap();
    HapticService().mediumTap();
    setState(() {
      _roleRevealed = true;
    });

    // Auto-close after 3 seconds
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _nextPlayer();
      }
    });
  }

  void _nextPlayer() {
    _autoCloseTimer?.cancel();
    setState(() {
      _roleRevealed = false;
    });

    if (_currentPlayerIndex < widget.players.length - 1) {
      setState(() {
        _currentPlayerIndex++;
      });
    } else {
      // All players have seen their roles, go to clue round
      setState(() {
        _phase = ImpostorPhase.clueRound;
        _currentPlayerIndex = 0;
      });
    }
  }

  void _nextCluePlayer() {
    AudioService().playTap();
    HapticService().lightTap();
    if (_currentPlayerIndex < widget.players.length - 1) {
      setState(() {
        _currentPlayerIndex++;
      });
    } else {
      // All clues given, go to voting
      _goToVoting();
    }
  }

  void _goToVoting() {
    AdsService().onRoundComplete();
    Navigator.of(context).pushReplacement(
      smoothRoute(VoteScreen(
        players: widget.players,
        impostor: _impostor,
        secretWord: _secretWord,
        category: _category,
      )),
    );
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case ImpostorPhase.distributing:
        return _buildDistributionScreen();
      case ImpostorPhase.showingRole:
        return _buildDistributionScreen();
      case ImpostorPhase.clueRound:
        return _buildClueRoundScreen();
      case ImpostorPhase.voting:
        return const SizedBox(); // handled by navigation
    }
  }

  Widget _buildDistributionScreen() {
    final isImpostor = _currentPlayer.name == _impostor.name;

    if (!_roleRevealed) {
      // Show "pass phone to X"
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                  alignment: Alignment.topLeft,
                ),
                const Spacer(),
                Text(
                  'Pasa el telefono a:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_currentPlayer.emoji} ${_currentPlayer.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 32),
                Text(
                  'Toca para ver tu rol',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                AnimatedButton(
                  text: '\u{1F441}\u{FE0F} VER ROL',
                  color: AppColors.cardBackground,
                  onPressed: _revealRole,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    // Show the role
    if (isImpostor) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text('\u{1F575}\u{FE0F}', style: TextStyle(fontSize: 80))
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 16),
                Text(
                  'ERES EL\nIMPOSTOR!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                  textAlign: TextAlign.center,
                ).animate().shake(duration: 500.ms),
                const SizedBox(height: 16),
                Text(
                  'Categoria: $_category',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Se cierra automaticamente...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    // Normal player - show the word
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'La palabra es:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                _secretWord.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.success,
                    ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 16),
              Text(
                'No la digas!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.warning,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'Se cierra automaticamente...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClueRoundScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'Ronda de pistas',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Di UNA palabra\nrelacionada',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Categoria: $_category',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.accent,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedButton(
                text: 'SIGUIENTE \u{25B6}',
                color: AppColors.success,
                onPressed: _nextCluePlayer,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

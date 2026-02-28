import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../models/player.dart';
import '../../widgets/animated_button.dart';
import '../../services/audio_service.dart';
import '../../services/haptic_service.dart';
import '../../utils/navigation_utils.dart';
import '../games/impostor_screen.dart';
import '../game_selector_screen.dart';

class VoteScreen extends StatefulWidget {
  final List<Player> players;
  final Player impostor;
  final String secretWord;
  final String category;

  const VoteScreen({
    super.key,
    required this.players,
    required this.impostor,
    required this.secretWord,
    required this.category,
  });

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final Map<String, String> _votes = {}; // voterName -> votedName
  int _currentVoterIndex = 0;
  bool _showingVoterPrompt = true;
  bool _votingComplete = false;

  Player get _currentVoter => widget.players[_currentVoterIndex];

  @override
  Widget build(BuildContext context) {
    if (_votingComplete) {
      return _buildResultScreen();
    }

    if (_showingVoterPrompt) {
      return _buildVoterPrompt();
    }

    return _buildVotingScreen();
  }

  Widget _buildVoterPrompt() {
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
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Text('\u{1F5F3}\u{FE0F}', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                Text(
                  'A votar!',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quien es el impostor?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Pasa el telefono a:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentVoter.emoji} ${_currentVoter.name}',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const Spacer(),
                AnimatedButton(
                  text: 'VOTAR',
                  gradient: AppColors.primaryGradient,
                  onPressed: () {
                    setState(() {
                      _showingVoterPrompt = false;
                    });
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

  Widget _buildVotingScreen() {
    final votablePlayers =
        widget.players.where((p) => p.name != _currentVoter.name).toList();

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
                const SizedBox(height: 8),
                Text(
                  '${_currentVoter.emoji} ${_currentVoter.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Vota al sospechoso:',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: votablePlayers.length,
                    itemBuilder: (context, index) {
                      final player = votablePlayers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: GestureDetector(
                          onTap: () => _submitVote(player.name),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withValues(alpha: 0.04),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                Text(player.emoji,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 16),
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.how_to_vote_rounded,
                                    color: AppColors.textMuted, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(
                            duration: 200.ms,
                            delay: Duration(milliseconds: 60 * index),
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

  void _submitVote(String votedName) {
    AudioService().playVote();
    HapticService().mediumTap();

    _votes[_currentVoter.name] = votedName;

    if (_currentVoterIndex < widget.players.length - 1) {
      setState(() {
        _currentVoterIndex++;
        _showingVoterPrompt = true;
      });
    } else {
      setState(() {
        _votingComplete = true;
      });
      AudioService().playReveal();
    }
  }

  Widget _buildResultScreen() {
    final Map<String, int> voteCount = {};
    for (final votedName in _votes.values) {
      voteCount[votedName] = (voteCount[votedName] ?? 0) + 1;
    }

    final sortedEntries = voteCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostVoted = sortedEntries.isNotEmpty ? sortedEntries.first.key : '';
    final groupWon = mostVoted == widget.impostor.name;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              (groupWon ? AppColors.success : AppColors.primary)
                  .withValues(alpha: 0.12),
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
                  'El impostor era:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                Text(
                  '${widget.impostor.emoji} ${widget.impostor.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 12),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.accent.withValues(alpha: 0.1),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'La palabra era: ${widget.secretWord}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),

                // Vote results
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    children: sortedEntries.map((entry) {
                      final player = widget.players.firstWhere(
                        (p) => p.name == entry.key,
                      );
                      final isImpostor =
                          entry.key == widget.impostor.name;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(player.emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isImpostor
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                  fontWeight: isImpostor
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Text(
                              '${entry.value} voto${entry.value > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (isImpostor)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Text('\u{2713}',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                Text(
                  groupWon
                      ? '\u{1F389} El grupo GANO!'
                      : '\u{1F575}\u{FE0F} El impostor GANO!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 26,
                        color:
                            groupWon ? AppColors.success : AppColors.primary,
                      ),
                ).animate().fadeIn(delay: 800.ms).shake(delay: 800.ms),

                const Spacer(),

                AnimatedButton(
                  text: 'OTRA RONDA',
                  gradient: AppColors.successGradient,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      smoothRoute(ImpostorScreen(players: widget.players)),
                    );
                  },
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
}

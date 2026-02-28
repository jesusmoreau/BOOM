import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/player.dart';
import '../utils/random_utils.dart';
import '../widgets/animated_button.dart';
import '../widgets/player_card.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../utils/navigation_utils.dart';
import 'game_selector_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final List<Player> _players = [];
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadSavedPlayers();
  }

  Future<void> _loadSavedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPlayersJson = prefs.getString('savedPlayers');
    if (savedPlayersJson != null) {
      final List<dynamic> decoded = jsonDecode(savedPlayersJson);
      setState(() {
        _players.addAll(
          decoded.map((e) => Player.fromJson(e as Map<String, dynamic>)),
        );
      });
    }
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_players.map((p) => p.toJson()).toList());
    await prefs.setString('savedPlayers', encoded);
  }

  static const List<String> _firstWords = [
    'Dinosaurio', 'Estrella', 'Banana', 'Capitan', 'Galleta',
    'Pulpo', 'Taco', 'Unicornio', 'Pirata', 'Robot',
    'Mono', 'Pepino', 'Dragon', 'Patata', 'Ninja',
    'Pingüino', 'Pantera', 'Tomate', 'Mapache', 'Churro',
    'Profesor', 'Cactus', 'Flamenco', 'Koala', 'Aguacate',
    'Mango', 'Tortuga', 'Perrito', 'Abuela', 'Tiburon',
  ];

  static const List<String> _secondWords = [
    'Dormilon', 'Furioso', 'Cosmico', 'Veloz', 'Salvaje',
    'Dorado', 'Espacial', 'Elegante', 'Volador', 'Brillante',
    'Legendario', 'Toxico', 'Nocturno', 'Galactico', 'Feroz',
    'Magico', 'Picante', 'Travieso', 'Supremo', 'Rebelde',
    'Electrico', 'Nuclear', 'Invencible', 'Misterioso', 'Turbo',
    'Explosivo', 'Secreto', 'Radiante', 'Infernal', 'Epico',
  ];

  void _generateRandomName() {
    if (_players.length >= AppConstants.maxPlayers) return;
    final first = randomFrom(_firstWords);
    final second = randomFrom(_secondWords);
    _nameController.text = '$first $second';
    AudioService().playTap();
    HapticService().lightTap();
  }

  void _addPlayer() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_players.length >= AppConstants.maxPlayers) return;

    final usedEmojis = _players.map((p) => p.emoji).toList();
    final emoji = randomPlayerEmoji(usedEmojis);

    setState(() {
      _players.add(Player(name: name, emoji: emoji));
      _nameController.clear();
    });
    _savePlayers();
    AudioService().playCorrect();
    HapticService().lightTap();
    _focusNode.requestFocus();
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
    _savePlayers();
    HapticService().lightTap();
  }

  void _editPlayer(int index) {
    final player = _players[index];
    final editController = TextEditingController(text: player.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '${player.emoji} Editar nombre',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: editController,
            autofocus: true,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Nombre del jugador...',
            ),
            onSubmitted: (_) {
              final newName = editController.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _players[index] = Player(name: newName, emoji: player.emoji);
                });
                _savePlayers();
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newName = editController.text.trim();
                if (newName.isNotEmpty) {
                  setState(() {
                    _players[index] = Player(name: newName, emoji: player.emoji);
                  });
                  _savePlayers();
                  AudioService().playCorrect();
                }
                Navigator.of(context).pop();
              },
              child: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _goToGameSelector() {
    if (_players.length < AppConstants.minPlayers) return;
    AudioService().playWhoosh();
    Navigator.of(context).push(
      smoothRoute(GameSelectorScreen(players: _players)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasEnough = _players.length >= AppConstants.minPlayers;

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
                            'Jugadores',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            '${_players.length} de ${AppConstants.maxPlayers}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Counter badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: hasEnough
                              ? AppColors.successGradient
                              : [AppColors.textMuted, AppColors.textMuted],
                        ),
                      ),
                      child: Text(
                        '${_players.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: hasEnough ? AppColors.background : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Nombre del jugador...',
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Dado random
                    GestureDetector(
                      onTap: _players.length < AppConstants.maxPlayers
                          ? _generateRandomName
                          : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.warning.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '\u{1F3B2}',
                            style: TextStyle(
                              fontSize: 22,
                              color: _players.length < AppConstants.maxPlayers
                                  ? null
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Boton agregar
                    GestureDetector(
                      onTap: _players.length < AppConstants.maxPlayers
                          ? _addPlayer
                          : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: _players.length < AppConstants.maxPlayers
                              ? const LinearGradient(
                                  colors: AppColors.accentGradient,
                                )
                              : null,
                          color: _players.length >= AppConstants.maxPlayers
                              ? AppColors.surface
                              : null,
                          boxShadow: _players.length < AppConstants.maxPlayers
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Player list
                Expanded(
                  child: _players.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '\u{1F464}',
                                style: TextStyle(
                                    fontSize: 48,
                                    color:
                                        Colors.white.withValues(alpha: 0.1)),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Agrega al menos ${AppConstants.minPlayers} jugadores',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _players.length,
                          itemBuilder: (context, index) {
                            return PlayerCard(
                              player: _players[index],
                              onDelete: () => _removePlayer(index),
                              onEdit: () => _editPlayer(index),
                            )
                                .animate()
                                .fadeIn(duration: 200.ms)
                                .slideX(
                                  begin: 0.1,
                                  end: 0,
                                  duration: 200.ms,
                                  curve: Curves.easeOut,
                                );
                          },
                        ),
                ),

                const SizedBox(height: 16),

                // Next button
                AnimatedButton(
                  text: 'SIGUIENTE',
                  emoji: '\u{27A1}\u{FE0F}',
                  gradient: hasEnough
                      ? AppColors.successGradient
                      : null,
                  color: hasEnough ? null : AppColors.surface,
                  textColor: hasEnough ? Colors.white : AppColors.textMuted,
                  outlined: !hasEnough,
                  onPressed: _goToGameSelector,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

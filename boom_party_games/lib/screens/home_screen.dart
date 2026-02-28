import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/game_config.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../widgets/animated_button.dart';
import '../utils/navigation_utils.dart';
import 'player_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;

  // Duplicar las imagenes para loop infinito
  List<String> get _imagePaths {
    final paths = GameInfo.allGames
        .where((g) => g.imagePath != null)
        .map((g) => g.imagePath!)
        .toList();
    // Triplicar para scroll continuo
    return [...paths, ...paths, ...paths];
  }

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0A2E),
                  AppColors.background,
                  Color(0xFF0A0A1A),
                ],
              ),
            ),
          ),

          // Scrolling game images - film strip
          Positioned.fill(
            child: _buildFilmStrips(),
          ),

          // Dark overlay to keep logo readable
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.75,
                  colors: [
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),

          // Top and bottom fade
          Positioned.fill(
            child: Column(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1A0A2E),
                        const Color(0xFF1A0A2E).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF0A0A1A),
                        const Color(0xFF0A0A1A).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Settings
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        AudioService().playTap();
                        HapticService().lightTap();
                        Navigator.of(context).push(
                          smoothRoute(const SettingsScreen()),
                        );
                      },
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
                        child: const Icon(
                          Icons.settings_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Bomba con glow
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 80,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          blurRadius: 120,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                    child: const Text('\u{1F4A3}',
                        style: TextStyle(fontSize: 120)),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.96, 0.96),
                        end: const Offset(1.04, 1.04),
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      ),

                  const SizedBox(height: 24),

                  // Titulo
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ).createShader(bounds),
                    child: Text(
                      'BOOM!',
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 46,
                                color: Colors.white,
                                letterSpacing: 3,
                              ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 4),

                  Text(
                    'PARTY GAMES',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 6,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                  const Spacer(flex: 2),

                  // Boton
                  AnimatedButton(
                    text: 'JUGAR',
                    emoji: '\u{1F3AE}',
                    gradient: AppColors.primaryGradient,
                    onPressed: () {
                      Navigator.of(context).push(
                        smoothRoute(const PlayerSetupScreen()),
                      );
                    },
                  )
                      .animate()
                      .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 500.ms,
                        delay: 300.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(delay: 300.ms),

                  const Spacer(),

                  Text(
                    AppConstants.appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmStrips() {
    final images = _imagePaths;
    if (images.isEmpty) return const SizedBox();

    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return Stack(
          children: [
            // Strip 1 - goes up (left)
            Positioned(
              left: -10,
              top: 0,
              bottom: 0,
              width: 130,
              child: _buildStrip(images, _scrollController.value, true, -12),
            ),
            // Strip 2 - goes down (right)
            Positioned(
              right: -10,
              top: 0,
              bottom: 0,
              width: 130,
              child: _buildStrip(images, _scrollController.value, false, 12),
            ),
            // Strip 3 - goes up (center-left)
            Positioned(
              left: 100,
              top: 0,
              bottom: 0,
              width: 120,
              child: _buildStrip(images, _scrollController.value * 0.7, true, 5),
            ),
            // Strip 4 - goes down (center-right)
            Positioned(
              right: 100,
              top: 0,
              bottom: 0,
              width: 120,
              child: _buildStrip(images, _scrollController.value * 0.6, false, -5),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStrip(
      List<String> images, double progress, bool goUp, double rotation) {
    final itemHeight = 180.0;
    final totalHeight = images.length * itemHeight;
    final offset = (progress * totalHeight) % totalHeight;

    return Transform.rotate(
      angle: rotation * 3.14159 / 180,
      child: Opacity(
        opacity: 0.2,
        child: OverflowBox(
          maxHeight: totalHeight * 2,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, goUp ? -offset : offset - totalHeight),
            child: Column(
              children: List.generate(images.length * 2, (index) {
                final img = images[index % images.length];
                return Container(
                  height: itemHeight - 8,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/game_config.dart';
import 'game_icon.dart';

class GameCard extends StatefulWidget {
  final GameInfo gameInfo;
  final int playerCount;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.gameInfo,
    required this.playerCount,
    required this.onTap,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get _hasEnoughPlayers =>
      widget.playerCount >= widget.gameInfo.minPlayers;
  bool get _hasImage => widget.gameInfo.imagePath != null;

  Color get _gameAccent {
    switch (widget.gameInfo.type) {
      case GameType.wordBomb:
        return AppColors.primary;
      case GameType.impostor:
        return AppColors.purple;
      case GameType.threeInFive:
        return AppColors.warning;
      case GameType.soundChain:
        return AppColors.accent;
      case GameType.taboo:
        return AppColors.secondary;
      case GameType.truthOrDare:
        return const Color(0xFFFF4D6A);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showHowToPlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _HowToPlaySheet(
        gameInfo: widget.gameInfo,
        accentColor: _gameAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _hasEnoughPlayers;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: enabled ? (_) => _controller.forward() : null,
        onTapUp: enabled
            ? (_) {
                _controller.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: enabled ? () => _controller.reverse() : null,
        onTap: !enabled
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Necesitas al menos ${widget.gameInfo.minPlayers} jugadores',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: AppColors.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            : null,
        child: _hasImage
            ? _buildImageCard(enabled)
            : _buildIconCard(enabled),
      ),
    );
  }

  /// Card con imagen full-bleed de fondo
  Widget _buildImageCard(bool enabled) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _gameAccent.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image - aligned top to show title + characters
          Opacity(
            opacity: enabled ? 1.0 : 0.25,
            child: Image.asset(
              widget.gameInfo.imagePath!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Info button
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: _showHowToPlay,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          // Player count badge top-left
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withValues(alpha: 0.5),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_rounded,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 3),
                  Text(
                    '${widget.gameInfo.minPlayers}-${widget.gameInfo.maxPlayers}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card con icono CustomPaint (sin imagen)
  Widget _buildIconCard(bool enabled) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _gameAccent.withValues(alpha: enabled ? 0.15 : 0.05),
            AppColors.cardBackground.withValues(alpha: enabled ? 0.8 : 0.3),
          ],
        ),
        border: Border.all(
          color: _gameAccent.withValues(alpha: enabled ? 0.3 : 0.08),
          width: 1.5,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _gameAccent.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Info button
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showHowToPlay,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _gameAccent.withValues(alpha: 0.15),
                  border: Border.all(
                    color: _gameAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: _gameAccent.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameIcon(
                  type: widget.gameInfo.type,
                  size: 52,
                  enabled: enabled,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.gameInfo.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.gameInfo.description,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _gameAccent.withValues(
                        alpha: enabled ? 0.12 : 0.04),
                  ),
                  child: Text(
                    '${widget.gameInfo.minPlayers}-${widget.gameInfo.maxPlayers} jugadores',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: enabled
                          ? _gameAccent.withValues(alpha: 0.9)
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowToPlaySheet extends StatelessWidget {
  final GameInfo gameInfo;
  final Color accentColor;

  const _HowToPlaySheet({
    required this.gameInfo,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.surface,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 20),

            // Game header
            if (gameInfo.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  gameInfo.imagePath!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(
                gameInfo.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            const SizedBox(height: 8),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
              ).createShader(bounds),
              child: Text(
                gameInfo.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${gameInfo.minPlayers}-${gameInfo.maxPlayers} jugadores',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // How to play steps
            ...List.generate(gameInfo.howToPlay.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          gameInfo.howToPlay[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: accentColor.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'ENTENDIDO',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

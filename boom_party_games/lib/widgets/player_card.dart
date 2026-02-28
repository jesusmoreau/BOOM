import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/player.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool showLives;
  final bool isActive;

  const PlayerCard({
    super.key,
    required this.player,
    this.onDelete,
    this.onEdit,
    this.showLives = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isActive
                ? [
                    AppColors.accent.withValues(alpha: 0.12),
                    AppColors.cardBackground.withValues(alpha: 0.6),
                  ]
                : [
                    AppColors.surface,
                    AppColors.surface.withValues(alpha: 0.8),
                  ],
          ),
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji avatar con fondo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Text(player.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: player.isEliminated
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: player.isEliminated
                            ? TextDecoration.lineThrough
                            : null,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),
            if (showLives)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      i < player.lives ? Icons.favorite : Icons.favorite_border,
                      color: i < player.lives
                          ? AppColors.primary
                          : AppColors.textMuted.withValues(alpha: 0.3),
                      size: 18,
                    ),
                  ),
                ),
              ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

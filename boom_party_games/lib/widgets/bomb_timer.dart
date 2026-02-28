import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../utils/timer_utils.dart';

class BombTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onExplode;
  final bool showFuse;

  const BombTimer({
    super.key,
    required this.durationSeconds,
    required this.onExplode,
    this.showFuse = true,
  });

  @override
  State<BombTimer> createState() => _BombTimerState();
}

class _BombTimerState extends State<BombTimer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _countdownTimer;
  late Timer _tickTimer;
  int _secondsLeft = 0;
  bool _exploded = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.durationSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: bombPulseInterval(_secondsLeft),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_exploded) return;
      setState(() {
        _secondsLeft--;
        _pulseController.duration = bombPulseInterval(_secondsLeft);
        _pulseController.repeat(reverse: true);
      });

      if (_secondsLeft <= 0) {
        _explode();
      }
    });

    _startTickTimer();
  }

  void _startTickTimer() {
    _tickTimer = Timer.periodic(bombPulseInterval(_secondsLeft), (timer) {
      if (_exploded) return;
      AudioService().playBombTick();
      HapticService().bombTick();
      _tickTimer.cancel();
      if (!_exploded) _startTickTimer();
    });
  }

  void _explode() {
    if (_exploded) return;
    _exploded = true;
    _countdownTimer.cancel();
    _tickTimer.cancel();
    AudioService().playExplosion();
    HapticService().explosion();
    widget.onExplode();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownTimer.cancel();
    _tickTimer.cancel();
    super.dispose();
  }

  Color get _fuseColor {
    final ratio = _secondsLeft / widget.durationSeconds;
    if (ratio > 0.5) return AppColors.secondary;
    if (ratio > 0.25) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final fuseProgress = _secondsLeft / widget.durationSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bomba con glow dinamico
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _fuseColor.withValues(alpha: 0.3 * _pulseAnimation.value),
                      blurRadius: 40 * _pulseAnimation.value,
                      spreadRadius: 5 * _pulseAnimation.value,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: const Text('\u{1F4A3}', style: TextStyle(fontSize: 80)),
        ),
        if (widget.showFuse) ...[
          const SizedBox(height: 16),
          // Mecha con gradiente
          SizedBox(
            width: 200,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  // Background
                  Container(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  // Progress
                  FractionallySizedBox(
                    widthFactor: fuseProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_fuseColor, _fuseColor.withValues(alpha: 0.6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _fuseColor.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

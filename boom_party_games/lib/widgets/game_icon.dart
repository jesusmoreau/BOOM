import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/game_config.dart';

class GameIcon extends StatelessWidget {
  final GameType type;
  final double size;
  final bool enabled;

  const GameIcon({
    super.key,
    required this.type,
    this.size = 56,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GameIconPainter(type: type, enabled: enabled),
      ),
    );
  }
}

class _GameIconPainter extends CustomPainter {
  final GameType type;
  final bool enabled;

  _GameIconPainter({required this.type, required this.enabled});

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) {
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withValues(alpha: 0.2),
      );
    }

    switch (type) {
      case GameType.wordBomb:
        _paintBomb(canvas, size);
        break;
      case GameType.impostor:
        _paintImpostor(canvas, size);
        break;
      case GameType.threeInFive:
        _paintLightning(canvas, size);
        break;
      case GameType.soundChain:
        _paintSoundWave(canvas, size);
        break;
      case GameType.taboo:
        _paintTaboo(canvas, size);
        break;
      case GameType.truthOrDare:
        _paintFlame(canvas, size);
        break;
    }

    if (!enabled) {
      canvas.restore();
    }
  }

  void _paintBomb(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 3;
    final r = size.width * 0.32;

    // Bomb body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          const Color(0xFF4A4A4A),
          const Color(0xFF1A1A1A),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // Highlight
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.5),
        radius: 0.6,
        colors: [
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, highlightPaint);

    // Fuse
    final fusePaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fusePath = Path()
      ..moveTo(cx + r * 0.5, cy - r * 0.8)
      ..quadraticBezierTo(
        cx + r * 0.9, cy - r * 1.3,
        cx + r * 0.4, cy - r * 1.5,
      );
    canvas.drawPath(fusePath, fusePaint);

    // Spark
    final sparkCenter = Offset(cx + r * 0.4, cy - r * 1.5);
    _paintSpark(canvas, sparkCenter, 6);
  }

  void _paintSpark(Canvas canvas, Offset center, double radius) {
    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.warning,
          AppColors.primary.withValues(alpha: 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
          Rect.fromCircle(center: center, radius: radius * 2.5));
    canvas.drawCircle(center, radius * 2.5, glowPaint);

    // Core
    final corePaint = Paint()..color = const Color(0xFFFFF3B0);
    canvas.drawCircle(center, radius * 0.6, corePaint);
  }

  void _paintImpostor(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.35;

    // Body
    final bodyPath = Path();
    bodyPath.addRRect(RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.2), width: s * 1.4, height: s * 1.6),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    ));
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.purple, AppColors.purple.withValues(alpha: 0.7)],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: s * 2, height: s * 2));
    canvas.drawPath(bodyPath, bodyPaint);

    // Visor
    final visorPath = Path();
    visorPath.addRRect(RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(cx + s * 0.15, cy - s * 0.15), width: s * 1.1, height: s * 0.65),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(10),
    ));
    final visorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF90CAF9),
          const Color(0xFF42A5F5),
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: s * 2, height: s * 2));
    canvas.drawPath(visorPath, visorPaint);

    // Visor shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(cx + s * 0.3, cy - s * 0.25), s * 0.1, shinePaint);

    // Question mark
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: s * 0.6,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy + s * 0.3),
    );
  }

  void _paintLightning(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.35;

    // Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.warning.withValues(alpha: 0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: s * 2));
    canvas.drawCircle(Offset(cx, cy), s * 2, glowPaint);

    // Lightning bolt
    final boltPath = Path()
      ..moveTo(cx + s * 0.1, cy - s * 1.2)
      ..lineTo(cx - s * 0.4, cy - s * 0.1)
      ..lineTo(cx + s * 0.05, cy - s * 0.1)
      ..lineTo(cx - s * 0.15, cy + s * 1.2)
      ..lineTo(cx + s * 0.5, cy + s * 0.05)
      ..lineTo(cx + s * 0.05, cy + s * 0.05)
      ..close();

    final boltPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFE082),
          AppColors.warning,
          const Color(0xFFFF8F00),
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: s * 2, height: s * 3));
    canvas.drawPath(boltPath, boltPaint);

    // Inner glow
    final innerGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        colors: [
          Colors.white.withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy - s * 0.2), radius: s * 0.5));
    canvas.drawCircle(Offset(cx, cy - s * 0.2), s * 0.5, innerGlow);
  }

  void _paintSoundWave(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.12;

    // Speaker body
    final speakerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.accent, const Color(0xFF00ACC1)],
      ).createShader(
          Rect.fromCenter(center: Offset(cx, cy), width: s * 8, height: s * 8));

    final speakerPath = Path()
      ..moveTo(cx - s * 2, cy - s * 0.8)
      ..lineTo(cx - s * 0.8, cy - s * 0.8)
      ..lineTo(cx + s * 0.3, cy - s * 1.8)
      ..lineTo(cx + s * 0.3, cy + s * 1.8)
      ..lineTo(cx - s * 0.8, cy + s * 0.8)
      ..lineTo(cx - s * 2, cy + s * 0.8)
      ..close();
    canvas.drawPath(speakerPath, speakerPaint);

    // Sound waves
    for (int i = 0; i < 3; i++) {
      final wavePaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.7 - i * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      final waveRadius = s * (1.5 + i * 1.2);
      final rect = Rect.fromCircle(
        center: Offset(cx + s * 0.3, cy),
        radius: waveRadius,
      );
      canvas.drawArc(rect, -pi / 4, pi / 2, false, wavePaint);
    }
  }

  void _paintTaboo(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.34;

    // Circle
    final circlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.secondary, const Color(0xFF00E5FF)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    circlePaint.style = PaintingStyle.stroke;
    circlePaint.strokeWidth = 3.5;
    canvas.drawCircle(Offset(cx, cy), r, circlePaint);

    // Cross line
    final crossPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary, const Color(0xFFFF6B6B)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    crossPaint.strokeWidth = 3.5;
    crossPaint.strokeCap = StrokeCap.round;

    final angle = -pi / 4;
    canvas.drawLine(
      Offset(cx + r * cos(angle), cy + r * sin(angle)),
      Offset(cx - r * cos(angle), cy - r * sin(angle)),
      crossPaint,
    );

    // Text "ABC"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ABC',
        style: TextStyle(
          fontSize: r * 0.55,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary.withValues(alpha: 0.7),
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  void _paintFlame(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width * 0.3;

    // Outer flame
    final outerPath = Path()
      ..moveTo(cx, cy - s * 1.5)
      ..cubicTo(
        cx + s * 0.8, cy - s * 0.8,
        cx + s * 1.2, cy + s * 0.2,
        cx + s * 0.6, cy + s * 1.0,
      )
      ..cubicTo(
        cx + s * 0.3, cy + s * 1.3,
        cx - s * 0.3, cy + s * 1.3,
        cx - s * 0.6, cy + s * 1.0,
      )
      ..cubicTo(
        cx - s * 1.2, cy + s * 0.2,
        cx - s * 0.8, cy - s * 0.8,
        cx, cy - s * 1.5,
      );

    final outerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6B35),
          AppColors.primary,
          const Color(0xFFCC0000),
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: s * 3, height: s * 3));
    canvas.drawPath(outerPath, outerPaint);

    // Inner flame
    final innerPath = Path()
      ..moveTo(cx, cy - s * 0.6)
      ..cubicTo(
        cx + s * 0.4, cy - s * 0.2,
        cx + s * 0.5, cy + s * 0.3,
        cx + s * 0.2, cy + s * 0.7,
      )
      ..cubicTo(
        cx + s * 0.1, cy + s * 0.85,
        cx - s * 0.1, cy + s * 0.85,
        cx - s * 0.2, cy + s * 0.7,
      )
      ..cubicTo(
        cx - s * 0.5, cy + s * 0.3,
        cx - s * 0.4, cy - s * 0.2,
        cx, cy - s * 0.6,
      );

    final innerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFE082),
          const Color(0xFFFFB74D),
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(cx, cy), width: s * 2, height: s * 2));
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _GameIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.enabled != enabled;
}

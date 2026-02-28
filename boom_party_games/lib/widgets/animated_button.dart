import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final List<Color>? gradient;
  final Color? textColor;
  final double height;
  final IconData? icon;
  final String? emoji;
  final bool outlined;
  final bool small;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.gradient,
    this.textColor,
    this.height = 64,
    this.icon,
    this.emoji,
    this.outlined = false,
    this.small = false,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    HapticService().lightTap();
    AudioService().playTap();
    widget.onPressed();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradient ??
        (widget.color != null
            ? [widget.color!, widget.color!.withValues(alpha: 0.8)]
            : AppColors.primaryGradient);
    final isOutlined = widget.outlined;
    final fontSize = widget.small ? 16.0 : 20.0;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isOutlined ? null : LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            color: isOutlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(widget.small ? 14 : 18),
            border: isOutlined
                ? Border.all(
                    color: gradientColors.first.withValues(alpha: 0.6),
                    width: 1.5,
                  )
                : null,
            boxShadow: isOutlined
                ? null
                : [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: gradientColors.last.withValues(alpha: 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: TextStyle(fontSize: fontSize + 4)),
                  const SizedBox(width: 10),
                ],
                if (widget.icon != null) ...[
                  Icon(widget.icon,
                      color: widget.textColor ?? Colors.white,
                      size: fontSize + 6),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor ??
                        (isOutlined
                            ? gradientColors.first
                            : Colors.white),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

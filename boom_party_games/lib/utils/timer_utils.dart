import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Devuelve el color del timer según los segundos restantes
Color timerColor(int secondsLeft, int totalSeconds) {
  final ratio = secondsLeft / totalSeconds;
  if (ratio > 0.6) return AppColors.success;
  if (ratio > 0.3) return AppColors.warning;
  return AppColors.primary;
}

/// Calcula el intervalo de latido de la bomba según los segundos restantes
Duration bombPulseInterval(int secondsLeft) {
  if (secondsLeft > 10) return const Duration(milliseconds: 1500);
  if (secondsLeft > 5) return const Duration(milliseconds: 800);
  if (secondsLeft > 3) return const Duration(milliseconds: 400);
  return const Duration(milliseconds: 150);
}

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../utils/random_utils.dart';

const List<String> penalties = [
  "Bebe un trago \u{1F37A}",
  "Haz 10 flexiones \u{1F4AA}",
  "Imita al jugador de tu derecha \u{1F3AD}",
  "Cuenta un chiste AHORA \u{1F602}",
  "Selfie con cara ridicula \u{1F4F8}",
  "Habla como robot durante la siguiente ronda \u{1F916}",
  "Canta una cancion que elija el grupo \u{1F3A4}",
  "No puedes usar las manos en la siguiente ronda \u{270B}",
  "Di un piropo al jugador de tu izquierda \u{1F495}",
  "Haz un sonido de animal durante 10 segundos \u{1F42E}",
  "Baila 15 segundos \u{1F483}",
  "Llama a alguien y cantale 'Cumpleanos Feliz' \u{1F4DE}",
  "Intercambia una prenda con otro jugador \u{1F455}",
  "No puedes hablar en la proxima ronda (solo gestos) \u{1F92B}",
  "Di todo al reves en la siguiente ronda \u{1F504}",
];

class PenaltyDisplay extends StatelessWidget {
  final String penalty;

  const PenaltyDisplay({super.key, required this.penalty});

  factory PenaltyDisplay.random({Key? key}) {
    return PenaltyDisplay(key: key, penalty: randomFrom(penalties));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'CASTIGO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            penalty,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

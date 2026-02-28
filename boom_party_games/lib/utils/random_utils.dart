import 'dart:math';
import '../config/constants.dart';

final _random = Random();

/// Genera un tiempo aleatorio para la bomba (en segundos)
int randomBombTime({int min = AppConstants.wordBombTimerMin, int max = AppConstants.wordBombTimerMax}) {
  return min + _random.nextInt(max - min + 1);
}

/// Selecciona un emoji aleatorio para un jugador
String randomPlayerEmoji(List<String> usedEmojis) {
  final available = AppConstants.playerEmojis.where((e) => !usedEmojis.contains(e)).toList();
  if (available.isEmpty) return AppConstants.playerEmojis[_random.nextInt(AppConstants.playerEmojis.length)];
  return available[_random.nextInt(available.length)];
}

/// Genera un índice aleatorio
int randomIndex(int max) => _random.nextInt(max);

/// Selecciona un elemento aleatorio de una lista
T randomFrom<T>(List<T> list) {
  return list[_random.nextInt(list.length)];
}

/// Baraja una lista (Fisher-Yates)
List<T> shuffle<T>(List<T> list) {
  final shuffled = List<T>.from(list);
  for (int i = shuffled.length - 1; i > 0; i--) {
    final j = _random.nextInt(i + 1);
    final temp = shuffled[i];
    shuffled[i] = shuffled[j];
    shuffled[j] = temp;
  }
  return shuffled;
}

/// Mensaje de explosión aleatorio
String randomExplosionMessage() {
  return randomFrom(AppConstants.explosionMessages);
}

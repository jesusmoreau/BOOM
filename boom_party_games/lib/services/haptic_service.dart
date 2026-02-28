import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _vibrationEnabled = true;
  bool _hasVibrator = false;

  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _hasVibrator = (await Vibration.hasVibrator()) == true;
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', enabled);
  }

  /// Vibración corta para taps
  Future<void> lightTap() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 30);
  }

  /// Vibración media para eventos de juego
  Future<void> mediumTap() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 80);
  }

  /// Vibración del tick de la bomba
  Future<void> bombTick() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 50);
  }

  /// Vibración larga para explosión
  Future<void> explosion() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(duration: 500);
  }

  /// Patrón de vibración para error/wrong
  Future<void> wrong() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 100, 50, 100]);
  }

  /// Vibración de éxito
  Future<void> success() async {
    if (!_vibrationEnabled || !_hasVibrator) return;
    await Vibration.vibrate(pattern: [0, 50, 30, 50, 30, 50]);
  }
}

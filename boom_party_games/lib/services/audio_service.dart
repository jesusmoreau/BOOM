import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _bombTickPlayer = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }

  Future<void> _playSfx(String asset) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setSource(AssetSource(asset));
      await _sfxPlayer.resume();
    } catch (_) {
      // Sound file not available — continue silently
    }
  }

  Future<void> playTap() => _playSfx('sounds/tap.wav');
  Future<void> playCorrect() => _playSfx('sounds/correct.wav');
  Future<void> playWrong() => _playSfx('sounds/wrong.wav');
  Future<void> playExplosion() => _playSfx('sounds/bomb_explode.wav');
  Future<void> playReveal() => _playSfx('sounds/reveal.wav');
  Future<void> playVictory() => _playSfx('sounds/victory.wav');
  Future<void> playChicken() => _playSfx('sounds/chicken.wav');
  Future<void> playTimerBeep() => _playSfx('sounds/timer_beep.wav');
  Future<void> playWhoosh() => _playSfx('sounds/whoosh.wav');
  Future<void> playVote() => _playSfx('sounds/vote.wav');

  Future<void> playBombTick() async {
    if (!_soundEnabled) return;
    try {
      await _bombTickPlayer.stop();
      await _bombTickPlayer.setSource(AssetSource('sounds/bomb_tick.wav'));
      await _bombTickPlayer.resume();
    } catch (_) {
      // Sound file not available — continue silently
    }
  }

  void dispose() {
    _sfxPlayer.dispose();
    _bombTickPlayer.dispose();
  }
}

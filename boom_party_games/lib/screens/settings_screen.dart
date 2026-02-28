import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _penaltiesEnabled = true;
  int _wordBombTimer = 1;
  int _threeInFiveTimer = 1;
  int _tabooTimer = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _penaltiesEnabled = prefs.getBool('penaltiesEnabled') ?? true;
      _wordBombTimer = prefs.getInt('wordBombTimer') ?? 1;
      _threeInFiveTimer = prefs.getInt('threeInFiveTimer') ?? 1;
      _tabooTimer = prefs.getInt('tabooTimer') ?? 1;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> _clearSavedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedPlayers');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jugadores eliminados'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppColors.textPrimary, size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Ajustes',
                        style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 8),
                    _sectionLabel('General'),
                    _buildToggle('Sonidos', _soundEnabled, (val) {
                      setState(() => _soundEnabled = val);
                      AudioService().setSoundEnabled(val);
                      _saveSetting('soundEnabled', val);
                    }),
                    _buildToggle('Vibracion', _vibrationEnabled, (val) {
                      setState(() => _vibrationEnabled = val);
                      HapticService().setVibrationEnabled(val);
                      _saveSetting('vibrationEnabled', val);
                    }),
                    _buildToggle('Castigos', _penaltiesEnabled, (val) {
                      setState(() => _penaltiesEnabled = val);
                      _saveSetting('penaltiesEnabled', val);
                    }),

                    const SizedBox(height: 24),
                    _sectionLabel('Timers'),
                    _buildSegmentedControl(
                      'Word Bomb',
                      ['Corto', 'Normal', 'Largo'],
                      _wordBombTimer,
                      (val) {
                        setState(() => _wordBombTimer = val);
                        _saveSetting('wordBombTimer', val);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSegmentedControl(
                      '3 en 5',
                      ['3s', '5s', '7s'],
                      _threeInFiveTimer,
                      (val) {
                        setState(() => _threeInFiveTimer = val);
                        _saveSetting('threeInFiveTimer', val);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSegmentedControl(
                      'Tabu',
                      ['30s', '60s', '90s'],
                      _tabooTimer,
                      (val) {
                        setState(() => _tabooTimer = val);
                        _saveSetting('tabooTimer', val);
                      },
                    ),

                    const SizedBox(height: 32),
                    _sectionLabel('Datos'),
                    GestureDetector(
                      onTap: _clearSavedPlayers,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.primary.withValues(alpha: 0.08),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded,
                                color: AppColors.primary.withValues(alpha: 0.8),
                                size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Borrar jugadores guardados',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'BOOM! ${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hecho con \u{2764}\u{FE0F}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(
    String label,
    List<String> options,
    int selectedIndex,
    ValueChanged<int> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: List.generate(options.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: AppColors.accentGradient,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        options[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _kStimuliKey = 'stimuliValue';
  static const String _kNKey = 'nValue';
  static const String _kGridKey = 'gridValue';

  // Load settings
  Future<Map<String, int>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'stimuli': prefs.getInt(_kStimuliKey) ?? 1,
      'nValue': prefs.getInt(_kNKey) ?? 1,
      'grid': prefs.getInt(_kGridKey) ?? 1,
    };
  }

  // Save stimuli value
  Future<void> saveStimuli(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStimuliKey, value);
  }

  // Save N value
  Future<void> saveNValue(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kNKey, value);
  }

  // Save grid value
  Future<void> saveGrid(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGridKey, value);
  }

  // Save all settings at once
  Future<void> saveAllSettings({
    required int stimuli,
    required int nValue,
    required int grid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStimuliKey, stimuli);
    await prefs.setInt(_kNKey, nValue);
    await prefs.setInt(_kGridKey, grid);
  }

  // Get stimuli value
  Future<int> getStimuliValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kStimuliKey) ?? 1;
  }

  // Get N value
  Future<int> getNValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kNKey) ?? 1;
  }

  // Get grid value
  Future<int> getGridValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kGridKey) ?? 1;
  }
}

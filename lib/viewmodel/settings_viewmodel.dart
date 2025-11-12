import 'package:flutter/material.dart';
import 'package:n_back/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository = SettingsRepository();

  int _stimuliValue = 1;
  int _nValue = 1;
  int _gridValue = 1;
  bool _isLoading = true;

  int get stimuliValue => _stimuliValue;
  int get nValue => _nValue;
  int get gridValue => _gridValue;
  bool get isLoading => _isLoading;

  int get gridSize => (_gridValue == 1) ? 3 : 5;

  SettingsViewModel() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _settingsRepository.loadSettings();
      _stimuliValue = settings['stimuli'] ?? 1;
      _nValue = settings['nValue'] ?? 1;
      _gridValue = settings['grid'] ?? 1;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setStimuli(int value) async {
    _stimuliValue = value;
    notifyListeners();
    try {
      await _settingsRepository.saveStimuli(value);
    } catch (e) {
      print('Error saving stimuli: $e');
    }
  }

  Future<void> setNValue(int value) async {
    _nValue = value;
    notifyListeners();
    try {
      await _settingsRepository.saveNValue(value);
    } catch (e) {
      print('Error saving N value: $e');
    }
  }

  Future<void> setGridValue(int value) async {
    _gridValue = value;
    notifyListeners();
    try {
      await _settingsRepository.saveGrid(value);
    } catch (e) {
      print('Error saving grid value: $e');
    }
  }

  Future<void> saveAllSettings() async {
    try {
      await _settingsRepository.saveAllSettings(
        stimuli: _stimuliValue,
        nValue: _nValue,
        grid: _gridValue,
      );
      notifyListeners();
    } catch (e) {
      print('Error saving settings: $e');
    }
  }
}

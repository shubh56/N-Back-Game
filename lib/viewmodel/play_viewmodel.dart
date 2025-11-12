import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:n_back/repositories/firebase_repository.dart';
import 'package:n_back/repositories/settings_repository.dart';

class PlayViewModel extends ChangeNotifier {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Settings
  int _stimuliValue = 1; // 1 = position-only, 2 = position+audio
  int _nValue = 1; // 1 or 2
  int _gridValue = 1; // 1 -> 3x3, 2 -> 5x5

  // Timings
  static const Duration stimulusDuration = Duration(milliseconds: 1000);
  static const Duration isiDuration = Duration(milliseconds: 700);
  static const int numTrials = 30;
  static const double matchProbability = 0.2;

  // Grid
  late int gridSize; // 3 or 5
  late int totalCells; // gridSize * gridSize

  // Letter pool for audio
  final List<String> letterPool = [
    'A',
    'C',
    'D',
    'E',
    'G',
    'H',
    'K',
    'L',
    'S',
    'T',
  ];
  final Random _rand = Random();

  // Sequences
  List<int> posSequence = [];
  List<String> audioSequence = [];

  // State
  bool _playing = false;
  bool _stimulusVisible = false;
  int _seqIndex = -1;
  int _currentPos = -1;
  String? _currentAudio;
  bool _pressedPosThisStim = false;
  bool _pressedAudioThisStim = false;
  int _preStartCountdown = 0;

  // Score tracking
  int _posHits = 0;
  int _posFalseAlarms = 0;
  int _posMisses = 0;
  int _audioHits = 0;
  int _audioFalseAlarms = 0;
  int _audioMisses = 0;

  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  int get stimuliValue => _stimuliValue;
  int get nValue => _nValue;
  int get gridValue => _gridValue;
  bool get playing => _playing;
  bool get stimulusVisible => _stimulusVisible;
  int get seqIndex => _seqIndex;
  int get currentPos => _currentPos;
  String? get currentAudio => _currentAudio;
  bool get pressedPosThisStim => _pressedPosThisStim;
  bool get pressedAudioThisStim => _pressedAudioThisStim;
  int get preStartCountdown => _preStartCountdown;
  int get posHits => _posHits;
  int get posFalseAlarms => _posFalseAlarms;
  int get posMisses => _posMisses;
  int get audioHits => _audioHits;
  int get audioFalseAlarms => _audioFalseAlarms;
  int get audioMisses => _audioMisses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PlayViewModel() {
    _loadSettings();
  }

  // Reload settings when coming back to this screen
  Future<void> refreshSettings() async {
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.loadSettings();
      _stimuliValue = settings['stimuli'] ?? 1;
      _nValue = settings['nValue'] ?? 1;
      _gridValue = settings['grid'] ?? 1;
      gridSize = (_gridValue == 1) ? 3 : 5;
      totalCells = gridSize * gridSize;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generateSequences() {
    posSequence = List<int>.filled(numTrials, 0);
    audioSequence = List<String>.filled(numTrials, '');

    for (int i = 0; i < numTrials; i++) {
      if (i < _nValue) {
        posSequence[i] = _rand.nextInt(totalCells);
        audioSequence[i] = letterPool[_rand.nextInt(letterPool.length)];
      } else {
        if (_rand.nextDouble() < matchProbability) {
          posSequence[i] = posSequence[i - _nValue];
        } else {
          int next;
          do {
            next = _rand.nextInt(totalCells);
          } while (next == posSequence[i - _nValue]);
          posSequence[i] = next;
        }

        if (_rand.nextDouble() < matchProbability) {
          audioSequence[i] = audioSequence[i - _nValue];
        } else {
          String nextLetter;
          do {
            nextLetter = letterPool[_rand.nextInt(letterPool.length)];
          } while (nextLetter == audioSequence[i - _nValue]);
          audioSequence[i] = nextLetter;
        }
      }
    }
  }

  Future<void> startSession() async {
    if (_playing) return;

    _playing = true;
    _posHits = 0;
    _posFalseAlarms = 0;
    _posMisses = 0;
    _audioHits = 0;
    _audioFalseAlarms = 0;
    _audioMisses = 0;
    _seqIndex = -1;
    _currentPos = -1;
    _currentAudio = null;
    _stimulusVisible = false;
    _preStartCountdown = 3;
    notifyListeners();

    // Countdown 3..1
    for (int i = 3; i > 0; i--) {
      _preStartCountdown = i;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }

    _preStartCountdown = 0;
    notifyListeners();

    _generateSequences();

    for (int i = 0; i < numTrials; i++) {
      if (!_playing) break;

      _seqIndex = i;
      _currentPos = posSequence[i];
      _currentAudio = audioSequence[i];
      _stimulusVisible = true;
      _pressedPosThisStim = false;
      _pressedAudioThisStim = false;
      notifyListeners();

      if (_stimuliValue == 2) {
        try {
          await _audioPlayer.play(AssetSource('audio/${_currentAudio!}.mp3'));
        } catch (_) {}
      }

      await Future.delayed(stimulusDuration);

      final bool posIsMatch =
          (i >= _nValue && posSequence[i] == posSequence[i - _nValue]);
      final bool audioIsMatch =
          (i >= _nValue && audioSequence[i] == audioSequence[i - _nValue]);

      if (posIsMatch && !_pressedPosThisStim) {
        _posMisses++;
      }
      if (audioIsMatch && !_pressedAudioThisStim && _stimuliValue == 2) {
        _audioMisses++;
      }

      _stimulusVisible = false;
      _currentPos = -1;
      _currentAudio = null;
      notifyListeners();

      try {
        await _audioPlayer.stop();
      } catch (_) {}

      await Future.delayed(isiDuration);
    }

    _playing = false;
    _stimulusVisible = false;
    _seqIndex = -1;
    _currentPos = -1;
    _currentAudio = null;
    notifyListeners();

    // Save session to Firestore
    await _firebaseRepository.saveGameSession(
      posHits: _posHits,
      posMisses: _posMisses,
      posFalseAlarms: _posFalseAlarms,
      audioHits: _audioHits,
      audioMisses: _audioMisses,
      audioFalseAlarms: _audioFalseAlarms,
      numTrials: numTrials,
      nValue: _nValue,
      gridSize: gridSize,
      stimuliValue: _stimuliValue,
    );
  }

  void stopSession() {
    _playing = false;
    _stimulusVisible = false;
    _seqIndex = -1;
    _currentPos = -1;
    _currentAudio = null;
    _preStartCountdown = 0;
    notifyListeners();
  }

  void onPressPosition() {
    if (!_stimulusVisible || !_playing || _seqIndex < 0) return;
    if (_pressedPosThisStim) return;

    final bool isMatch =
        (_seqIndex >= _nValue &&
        posSequence[_seqIndex] == posSequence[_seqIndex - _nValue]);

    if (isMatch) {
      _posHits++;
    } else {
      _posFalseAlarms++;
    }
    _pressedPosThisStim = true;
    notifyListeners();
  }

  void onPressAudio() {
    if (_stimuliValue == 1) return;
    if (!_stimulusVisible || !_playing || _seqIndex < 0) return;
    if (_pressedAudioThisStim) return;

    final bool isMatch =
        (_seqIndex >= _nValue &&
        audioSequence[_seqIndex] == audioSequence[_seqIndex - _nValue]);

    if (isMatch) {
      _audioHits++;
    } else {
      _audioFalseAlarms++;
    }
    _pressedAudioThisStim = true;
    notifyListeners();
  }

  Map<String, int> getSessionSummary() {
    int posTotalMatches = 0;
    int audioTotalMatches = 0;

    for (int i = _nValue; i < posSequence.length; i++) {
      if (posSequence[i] == posSequence[i - _nValue]) posTotalMatches++;
      if (audioSequence[i] == audioSequence[i - _nValue]) audioTotalMatches++;
    }

    return {
      'posTotalMatches': posTotalMatches,
      'posHits': _posHits,
      'posMisses': _posMisses,
      'posFalseAlarms': _posFalseAlarms,
      'audioTotalMatches': audioTotalMatches,
      'audioHits': _audioHits,
      'audioMisses': _audioMisses,
      'audioFalseAlarms': _audioFalseAlarms,
    };
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

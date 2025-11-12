import 'package:flutter/material.dart';
import 'package:n_back/models/user_model.dart';
import 'package:n_back/repositories/firebase_repository.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  List<UserModel> _allUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Sort users by best position hits (descending)
  List<UserModel> get sortedByPosHits {
    final sorted = [..._allUsers];
    sorted.sort((a, b) => b.bestPosHits.compareTo(a.bestPosHits));
    return sorted;
  }

  // Sort users by best audio hits (descending)
  List<UserModel> get sortedByAudioHits {
    final sorted = [..._allUsers];
    sorted.sort((a, b) => b.bestAudioHits.compareTo(a.bestAudioHits));
    return sorted;
  }

  LeaderboardViewModel() {
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allUsers = await _firebaseRepository.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadAllUsers();
  }
}

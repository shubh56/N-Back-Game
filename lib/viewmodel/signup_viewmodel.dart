import 'package:flutter/material.dart';
import 'package:n_back/repositories/auth_repository.dart';
import 'package:n_back/repositories/firebase_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseRepository _firebaseRepository = FirebaseRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signUp(
        email: email,
        password: password,
      );

      if (result == 'Successful') {
        // Create user profile in Firestore
        final uid = _authRepository.currentUser?.uid;
        if (uid != null) {
          await _firebaseRepository.createUserProfile(
            uid: uid,
            email: email,
            name: name,
          );
        }
      } else {
        _errorMessage = result;
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

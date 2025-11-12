import 'package:flutter/material.dart';
import 'package:n_back/repositories/auth_repository.dart';

class SignInViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (result != 'Successful') {
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

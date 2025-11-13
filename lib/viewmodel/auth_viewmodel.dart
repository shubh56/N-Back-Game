// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:n_back/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  late Stream<User?> _authStream;
  User? _currentUser;
  bool _isLoading = true;

  AuthViewModel() {
    _authStream = _authRepository.authStateChanges;
    _currentUser = _authRepository.currentUser;
    _isLoading = false;
  }

  Stream<User?> get authStream => _authStream;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}

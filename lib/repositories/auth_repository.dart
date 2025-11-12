import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign up with email and password
  Future<String> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to create user with email: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User created: ${credential.user?.uid}');
      return 'Successful';
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        return 'Exists';
      } else if (e.code == 'weak-password') {
        return 'WeakPassword';
      } else if (e.code == 'invalid-email') {
        return 'InvalidEmail';
      } else {
        return e.message ?? e.code;
      }
    } catch (e, st) {
      print('Generic error: $e\n$st');
      return e.toString();
    }
  }

  // Sign in with email and password
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting to sign in user with email: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${credential.user?.uid}');
      return 'Successful';
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        return 'No User Exists';
      } else if (e.code == 'wrong-password') {
        return 'Wrong Password';
      } else {
        return e.message ?? e.code;
      }
    } catch (e, st) {
      print('Generic error: $e\n$st');
      return e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}

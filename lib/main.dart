import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n_back/views/leaderboard_screen/leaderboard_screen.dart';
import 'package:n_back/views/play_screen/play_screen.dart';
import 'package:n_back/views/settings/settings.dart';
import 'package:n_back/views/signin_screen.dart/signin_screen.dart';
import 'package:n_back/views/signup_screen/signup_screen.dart';
import 'package:n_back/firebase_options.dart';
import 'package:n_back/viewmodel/auth_viewmodel.dart';
import 'package:n_back/viewmodel/signin_viewmodel.dart';
import 'package:n_back/viewmodel/signup_viewmodel.dart';
import 'package:n_back/viewmodel/play_viewmodel.dart';
import 'package:n_back/viewmodel/leaderboard_viewmodel.dart';
import 'package:n_back/viewmodel/settings_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NBack());
}

class NBack extends StatelessWidget {
  const NBack({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SignInViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        // Game and Settings ViewModels
        ChangeNotifierProvider(create: (_) => PlayViewModel()),
        ChangeNotifierProvider(create: (_) => LeaderboardViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'N-Back Game',
        home: const AuthGate(),
        routes: {
          '/signup': (context) => const SignupScreen(),
          '/signin': (context) => const SigninScreen(),
          '/play': (context) => const NBackGamePage(),
          '/settings': (context) => const Settings(),
          '/leaderboard': (context) => const LeaderboardScreen(),
        },
      ),
    );
  }
}

/// Lightweight widget that routes the user depending on Firebase Auth state.
///
/// - Shows PlayScreen when a user is already signed in (persisted session).
/// - Shows SigninScreen when no user is signed in.
/// Uses authStateChanges() stream so it reacts to sign-in / sign-out automatically.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // while waiting for the initial auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is signed in, snapshot.data is non-null
        if (snapshot.hasData && snapshot.data != null) {
          return const NBackGamePage();
        }

        // Otherwise show sign-in
        return const SigninScreen();
      },
    );
  }
}

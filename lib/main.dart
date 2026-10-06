import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/donor_provider.dart';
import 'screens/donor_search_screen.dart';
import 'screens/home_shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/brand_logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const LifeDropApp());
}

/// Root widget of the LifeDrop Blood Donor Search & Request application.
class LifeDropApp extends StatelessWidget {
  const LifeDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // DonorProvider manages donors, search filters, and Firestore queries
        ChangeNotifierProvider(create: (_) => DonorProvider()),
      ],
      child: MaterialApp(
        title: 'LifeDrop – Blood Donor Search & Request',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Authentication wrapper checks if user is already signed in
        home: const AuthWrapper(),

        // Named routes for clean navigation flow
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          RegisterScreen.routeName: (context) => const RegisterScreen(),
          DonorSearchScreen.routeName: (context) => const HomeShellScreen(),
          HomeShellScreen.routeName: (context) => const HomeShellScreen(),
        },
      ),
    );
  }
}

/// AuthWrapper checks Firebase authentication state:
/// - If user is logged in -> routes directly to HomeShellScreen
/// - If not logged in -> routes to LoginScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While Firebase Auth is determining user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundWarm,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BrandLogo(size: 64, showText: true),
                  SizedBox(height: 28),
                  CircularProgressIndicator(
                    color: AppTheme.primaryRed,
                    strokeWidth: 2.5,
                  ),
                ],
              ),
            ),
          );
        }

        // If authenticated user exists, jump straight to HomeShellScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeShellScreen();
        }

        // Otherwise show LoginScreen
        return const LoginScreen();
      },
    );
  }
}

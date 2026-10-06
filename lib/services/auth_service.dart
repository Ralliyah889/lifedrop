import 'package:firebase_auth/firebase_auth.dart';

/// Service class that encapsulates all Firebase Authentication logic.
/// Keeps authentication concerns separate from the UI layer.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  /// Useful for reactive navigation based on login status.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in an existing user with email and password.
  /// Returns the [User] on success.
  /// Throws [FirebaseAuthException] on failure.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Registers a new user with email and password.
  /// Returns the [User] on success.
  /// Throws a user-friendly error message on failure.
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends a password reset email to the given address.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Converts Firebase auth error codes into user-friendly messages.
  String _handleAuthError(FirebaseAuthException e) {
    // ignore: avoid_print
    print('FirebaseAuthException code: "${e.code}", message: "${e.message}"');
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled yet in your Firebase Console. Please enable it in Authentication > Sign-in method.';
      case 'user-not-found':
        return 'No account found with this email. Please click "Create Account" below.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again in a few minutes.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again or create an account.';
      default:
        return e.message?.isNotEmpty == true
            ? e.message!
            : 'Authentication failed (${e.code}). Please check your credentials.';
    }
  }
}

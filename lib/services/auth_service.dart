import 'dart:async';

import '../models/auth_user.dart';
import 'supabase_client.dart';

class AuthResult {
  const AuthResult({required this.success, this.error, this.user});

  final bool success;
  final String? error;
  final AuthUser? user;
}

class AuthService {
  static const _timeout = Duration(seconds: 20);

  Future<AuthResult> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const AuthResult(success: false, error: 'Missing credentials');
    }
    try {
      final result = await AppSupabase.client.auth
          .signInWithPassword(email: email, password: password)
          .timeout(_timeout);
      final user = result.user;
      if (user == null) {
        return const AuthResult(
          success: false,
          error: 'Login failed - no user returned',
        );
      }

      return AuthResult(
        success: true,
        user: AuthUser(id: user.id, email: user.email ?? ''),
      );
    } on TimeoutException {
      return const AuthResult(success: false, error: 'Connection timed out');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<AuthResult> register(String email, String password) async {
    if (email.trim().isEmpty || password.length < 8) {
      return const AuthResult(
        success: false,
        error: 'Invalid registration data',
      );
    }
    try {
      final result = await AppSupabase.client.auth
          .signUp(email: email, password: password)
          .timeout(_timeout);
      final user = result.user;
      if (user == null) {
        return const AuthResult(
          success: false,
          error: 'Registration failed - no user returned',
        );
      }

      return AuthResult(
        success: true,
        user: AuthUser(id: user.id, email: user.email ?? ''),
      );
    } on TimeoutException {
      return const AuthResult(success: false, error: 'Connection timed out');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await AppSupabase.client.auth.signOut().timeout(_timeout);
    } catch (_) {}
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = AppSupabase.client.auth.currentUser;
      if (user == null) return null;
      return AuthUser(id: user.id, email: user.email ?? '');
    } catch (_) {
      return null;
    }
  }

  Stream<AuthUser?> authStateChanges() {
    return AppSupabase.client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return AuthUser(id: user.id, email: user.email ?? '');
    });
  }
}

final authService = AuthService();

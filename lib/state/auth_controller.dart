import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';

class AuthState {
  const AuthState({required this.user, required this.isLoading});

  final AuthUser? user;
  final bool isLoading;

  bool get isAuthenticated => user != null;

  AuthState copyWith({AuthUser? user, bool? isLoading}) {
    return AuthState(user: user, isLoading: isLoading ?? this.isLoading);
  }

  static const initial = AuthState(user: null, isLoading: true);
}

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AuthUser?>? _sub;
  bool _authActionInFlight = false;
  bool _disposed = false;

  @override
  AuthState build() {
    state = AuthState.initial;
    _initialize();
    return state;
  }

  Future<void> _initialize() async {
    try {
      final currentUser = await authService.getCurrentUser();
      state = state.copyWith(user: currentUser, isLoading: false);
      cloudSyncService.setUserId(currentUser?.id);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }

    _sub?.cancel();
    _sub = authService.authStateChanges().listen(
      (user) {
        if (_disposed) return;
        state = state.copyWith(user: user);
        cloudSyncService.setUserId(user?.id);
      },
      onError: (_) {
        if (!_disposed) state = state.copyWith(isLoading: false);
      },
    );

    ref.onDispose(() {
      _disposed = true;
      _sub?.cancel();
    });
  }

  Future<AuthResult> login(String email, String password) async {
    if (_authActionInFlight) {
      return const AuthResult(success: false, error: 'Request already running');
    }
    _authActionInFlight = true;
    try {
      final result = await authService.login(email, password);
      if (!_disposed && result.success && result.user != null) {
        state = state.copyWith(user: result.user);
        cloudSyncService.setUserId(result.user!.id);
      }
      return result;
    } finally {
      _authActionInFlight = false;
    }
  }

  Future<AuthResult> register(String email, String password) async {
    if (_authActionInFlight) {
      return const AuthResult(success: false, error: 'Request already running');
    }
    _authActionInFlight = true;
    try {
      final result = await authService.register(email, password);
      if (!_disposed && result.success && result.user != null) {
        state = state.copyWith(user: result.user);
        cloudSyncService.setUserId(result.user!.id);
      }
      return result;
    } finally {
      _authActionInFlight = false;
    }
  }

  Future<void> logout() async {
    if (_authActionInFlight) return;
    _authActionInFlight = true;
    try {
      await authService.logout();
      if (_disposed) return;
      state = state.copyWith(user: null);
      cloudSyncService.setUserId(null);
    } finally {
      _authActionInFlight = false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

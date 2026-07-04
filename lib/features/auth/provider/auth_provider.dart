import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesikil/core/utils/action_throttler.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/auth/models/user_model.dart';
import 'package:homesikil/features/auth/repository/auth_repository.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<UserModel?>? _authSubscription;

  final _loginThrottler = ActionThrottler();
  final _registerThrottler = ActionThrottler();
  final _resetPasswordThrottler = ActionThrottler();

  AuthProvider(this._repository) {
    _currentUser = _repository.getCurrentUser();
    if (_currentUser != null) {
      _status = AuthStatus.success;
    }

    _authSubscription = _repository.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _status = AuthStatus.success;
      } else if (_status != AuthStatus.error) {
        _status = AuthStatus.initial;
      }
      notifyListeners();
    });
  }

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  Duration _loginCooldown = Duration.zero;
  Duration _registerCooldown = Duration.zero;
  Duration _resetCooldown = Duration.zero;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  Duration get loginCooldown => _loginCooldown;
  Duration get registerCooldown => _registerCooldown;
  Duration get resetCooldown => _resetCooldown;

  Future<void> signIn({required String email, required String password}) async {
    if (!_loginThrottler.canAttempt) {
      _loginCooldown = _loginThrottler.remainingCooldown;
      notifyListeners();
      return;
    }
    _loginThrottler.recordAttempt();

    _status = AuthStatus.loading;
    _errorMessage = null;
    _loginCooldown = Duration.zero;
    notifyListeners();

    try {
      _currentUser = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      _status = AuthStatus.success;
      _loginThrottler.reset();
    } on Failure {
      _errorMessage = 'Email or password is incorrect';
      _status = AuthStatus.error;
      _loginThrottler.recordFailure();
      _loginCooldown = _loginThrottler.remainingCooldown;
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    if (!_registerThrottler.canAttempt) {
      _registerCooldown = _registerThrottler.remainingCooldown;
      notifyListeners();
      return;
    }
    _registerThrottler.recordAttempt();

    _status = AuthStatus.loading;
    _errorMessage = null;
    _registerCooldown = Duration.zero;
    notifyListeners();

    try {
      final user = await _repository.signUp(
        email: email.trim(),
        password: password,
        username: username.trim(),
      );
      _currentUser = user;
      _status = AuthStatus.success;
      _registerThrottler.reset();
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      _registerThrottler.recordFailure();
      _registerCooldown = _registerThrottler.remainingCooldown;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() => _signInWithOAuth(OAuthProvider.google);

  Future<void> signInWithDiscord() => _signInWithOAuth(OAuthProvider.discord);

  Future<void> _signInWithOAuth(OAuthProvider provider) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signInWithOAuth(provider);
      _status = AuthStatus.initial;
      notifyListeners();
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
      _currentUser = null;
      _status = AuthStatus.initial;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> resetPassword({required String email}) async {
    if (!_resetPasswordThrottler.canAttempt) {
      _resetCooldown = _resetPasswordThrottler.remainingCooldown;
      notifyListeners();
      return;
    }
    _resetPasswordThrottler.recordAttempt();

    _status = AuthStatus.loading;
    _errorMessage = null;
    _resetCooldown = Duration.zero;
    notifyListeners();

    try {
      await _repository.resetPassword(email: email.trim());
      _status = AuthStatus.success;
      _resetPasswordThrottler.reset();
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      _resetPasswordThrottler.recordFailure();
      _resetCooldown = _resetPasswordThrottler.remainingCooldown;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

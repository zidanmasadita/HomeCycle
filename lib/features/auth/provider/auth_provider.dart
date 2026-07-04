import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/auth/models/user_model.dart';
import 'package:homesikil/features/auth/repository/auth_repository.dart';

enum AuthStatus { initial, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<UserModel?>? _authSubscription;

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

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> signIn({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      _status = AuthStatus.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _repository.signUp(
        email: email.trim(),
        password: password,
        username: username.trim(),
      );
      _currentUser = user;
      _status = AuthStatus.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
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

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        password: password,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> resetPassword({required String email}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(email: email.trim());
      _status = AuthStatus.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

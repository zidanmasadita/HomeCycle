import 'dart:async';
import 'package:flutter/material.dart';
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
      _status = user != null ? AuthStatus.success : AuthStatus.initial;
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

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signUp(
        email: email,
        password: password,
        username: username,
      );
      _status = AuthStatus.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.signIn(
        email: email,
        password: password,
      );
      _status = AuthStatus.success;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
    }
    notifyListeners();
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
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.resetPassword(email: email);
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

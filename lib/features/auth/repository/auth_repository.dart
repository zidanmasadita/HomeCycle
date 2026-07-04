import 'package:homesikil/data/remote/supabase_service.dart';
import 'package:homesikil/errors/failure.dart';
import 'package:homesikil/features/auth/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _client = SupabaseService.client;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (response.user == null) {
        throw const Failure('Registration failed. Please try again.');
      }
      if (response.session == null) return null;
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('User tidak ditemukan setelah login');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    try {
      await _client.auth.signInWithOAuth(
        provider,
        redirectTo: 'homesikil://login-callback',
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? password,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (fullName != null && fullName.isNotEmpty) {
        data['username'] = fullName;
        data['full_name'] = fullName;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      await _client.auth.updateUser(
        UserAttributes(
          data: data.isNotEmpty ? data : null,
          password: (password != null && password.isNotEmpty) ? password : null,
        ),
      );
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Failure.fromException(e);
    }
  }

  UserModel? getCurrentUser() {
    final user = SupabaseService.currentUser;
    if (user != null) {
      return UserModel.fromSupabaseUser(user);
    }
    return null;
  }

  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }
      return null;
    });
  }
}

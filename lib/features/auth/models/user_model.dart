import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String? username;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    required this.createdAt,
  });

  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.phone,
    required this.createdAt,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: (metadata['username'] ?? metadata['name'] ?? metadata['full_name']) as String?,
      phone: metadata['phone'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }
}

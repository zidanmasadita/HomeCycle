import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const _url = 'https://jnogfilekntihduogfal.supabase.co';
  static const _anonKey = 'sb_publishable_1AzSKMtgZGgdpN6Y3FPuuw_nmc-1Ii8';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _url,
      // ignore: deprecated_member_use
      anonKey: _anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String get currentUserId {
    final user = currentUser;
    if (user == null) throw Exception('User belum login');
    return user.id;
  }
}

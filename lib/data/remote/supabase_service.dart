import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  // Nilai bawaan di bawah adalah konfigurasi proyek saat ini. Keduanya dapat
  // ditimpa ketika build/run melalui:
  //   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  // Catatan: publishable/anon key memang dirancang publik untuk aplikasi
  // klien; keamanan data bertumpu pada Row Level Security (RLS) di Supabase,
  // bukan pada kerahasiaan key ini. Jangan pernah memakai service_role key
  // di dalam aplikasi.
  static const _url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jnogfilekntihduogfal.supabase.co',
  );
  static const _anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_1AzSKMtgZGgdpN6Y3FPuuw_nmc-1Ii8',
  );

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

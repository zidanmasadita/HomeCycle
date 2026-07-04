import 'package:supabase_flutter/supabase_flutter.dart';

class Failure implements Exception {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  factory Failure.fromException(Object error) {
    if (error is Failure) return error;

    if (error is AuthException) {
      return Failure(_mapAuthError(error.message), code: error.statusCode);
    }

    final errorString = error.toString();

    if (errorString.contains('PostgresException')) {
      return const Failure(
        'A database error occurred. Please try again.',
        code: 'db_error',
      );
    }
    if (errorString.contains('SocketException') ||
        errorString.contains('ClientException')) {
      return const Failure('No internet connection.', code: 'network_error');
    }
    return const Failure(
      'An unexpected error occurred. Please try again.',
      code: 'unknown_error',
    );
  }

  static String _mapAuthError(String message) {
    final m = message.toLowerCase();
    if (m.contains('email already') ||
        m.contains('already registered') ||
        m.contains('user already')) {
      return 'This email is already registered. Please log in instead.';
    }
    if (m.contains('invalid') && m.contains('email')) {
      return 'Please enter a valid email address.';
    }
    if (m.contains('password') &&
        (m.contains('short') || m.contains('weak') || m.contains('length'))) {
      return 'Password must be at least 8 characters.';
    }
    if (m.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (m.contains('invalid login') ||
        m.contains('invalid credentials') ||
        m.contains('wrong password')) {
      return 'Email or password is incorrect.';
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (m.contains('network') || m.contains('connection')) {
      return 'Connection error. Please check your internet.';
    }
    return message;
  }

  @override
  String toString() => message;
}

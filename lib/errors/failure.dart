class Failure implements Exception {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  factory Failure.fromException(Object error) {
    final errorString = error.toString();

    if (errorString.contains('PostgresException')) {
      return Failure(
        'Terjadi kesalahan pada database. Coba lagi.',
        code: 'db_error',
      );
    }
    if (errorString.contains('AuthException')) {
      return Failure(
        'Sesi login bermasalah. Silahkan login ulang.',
        code: 'auth_error',
      );
    }
    if (errorString.contains('SocketException') ||
        errorString.contains('ClientException')) {
      return Failure('Tidak ada koneksi internet.', code: 'network_error');
    }
    return Failure(
      'Terjadi kesalahan tidak terduga. Coba lagi.',
      code: 'unknown_error',
    );
  }

  @override
  String toString() => message;
}

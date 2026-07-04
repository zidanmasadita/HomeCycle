class ActionThrottler {
  DateTime? _lastAttempt;
  int _consecutiveFailures = 0;

  Duration get cooldown {
    if (_consecutiveFailures == 0) return Duration.zero;
    final seconds = (2 << (_consecutiveFailures - 1)).clamp(2, 30);
    return Duration(seconds: seconds);
  }

  bool get canAttempt {
    if (_lastAttempt == null) return true;
    return DateTime.now().difference(_lastAttempt!) >= cooldown;
  }

  Duration get remainingCooldown {
    if (canAttempt) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastAttempt!);
    return cooldown - elapsed;
  }

  void recordAttempt() {
    _lastAttempt = DateTime.now();
  }

  void recordFailure() {
    _consecutiveFailures++;
    _lastAttempt = DateTime.now();
  }

  void reset() {
    _consecutiveFailures = 0;
    _lastAttempt = null;
  }
}

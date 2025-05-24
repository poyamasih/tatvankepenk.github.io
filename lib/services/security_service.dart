import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class that handles various security features
class SecurityService {
  static const String _loginAttemptsKey = 'login_attempts';
  static const String _loginBlockedUntilKey = 'login_blocked_until';
  static const String _lastActivityKey = 'last_activity_time';
  static const String _captchaStateKey = 'captcha_state';

  // Maximum login attempts before blocking
  static const int maxLoginAttempts = 5;

  // Default block time in minutes after max attempts
  static const int defaultBlockTimeMinutes = 15;

  // Session timeout in minutes (30 minutes)
  static const int sessionTimeoutMinutes = 30;

  final SharedPreferences _prefs;

  SecurityService(this._prefs);

  // LOGIN ATTEMPT LIMITATION FUNCTIONS

  /// Record a failed login attempt and check if login should be blocked
  Future<bool> recordFailedLoginAttempt() async {
    // If already blocked, check if block period is over
    if (isLoginBlocked()) {
      return true; // Still blocked
    }

    // Get current attempts count
    int attempts = _prefs.getInt(_loginAttemptsKey) ?? 0;
    attempts++;

    await _prefs.setInt(_loginAttemptsKey, attempts);

    // If max attempts reached, block login
    if (attempts >= maxLoginAttempts) {
      // Block for 15 minutes from now
      DateTime blockUntil = DateTime.now().add(
        Duration(minutes: defaultBlockTimeMinutes),
      );
      await _prefs.setString(
        _loginBlockedUntilKey,
        blockUntil.toIso8601String(),
      );
      return true;
    }

    return false; // Not blocked
  }

  /// Reset login attempts counter on successful login
  Future<void> resetLoginAttempts() async {
    await _prefs.remove(_loginAttemptsKey);
    await _prefs.remove(_loginBlockedUntilKey);
  }

  /// Check if login is currently blocked due to too many attempts
  bool isLoginBlocked() {
    String? blockedUntil = _prefs.getString(_loginBlockedUntilKey);
    if (blockedUntil == null) return false;

    DateTime blockTime = DateTime.parse(blockedUntil);
    return DateTime.now().isBefore(blockTime);
  }

  /// Get remaining time of block in seconds
  int getRemainingBlockTime() {
    String? blockedUntil = _prefs.getString(_loginBlockedUntilKey);
    if (blockedUntil == null) return 0;

    DateTime blockTime = DateTime.parse(blockedUntil);
    int remainingSeconds = blockTime.difference(DateTime.now()).inSeconds;
    return remainingSeconds > 0 ? remainingSeconds : 0;
  }

  // SESSION TIMEOUT FUNCTIONS

  /// Record activity to prevent session timeout
  Future<void> updateLastActivity() async {
    await _prefs.setString(_lastActivityKey, DateTime.now().toIso8601String());
  }

  /// Check if session has timed out
  bool hasSessionTimedOut() {
    String? lastActivity = _prefs.getString(_lastActivityKey);
    if (lastActivity == null) return true;

    DateTime lastActiveTime = DateTime.parse(lastActivity);
    Duration inactiveTime = DateTime.now().difference(lastActiveTime);

    return inactiveTime.inMinutes >= sessionTimeoutMinutes;
  }

  // CAPTCHA FUNCTIONS

  /// Generate a new CAPTCHA state
  Map<String, dynamic> generateCaptchaState() {
    // Generate a simple math-based CAPTCHA
    final random1 = (DateTime.now().millisecondsSinceEpoch % 10) + 1;
    final random2 = (DateTime.now().millisecondsSinceEpoch % 5) + 1;

    final sum = random1 + random2;

    Map<String, dynamic> captchaState = {
      'question': '$random1 + $random2 = ?',
      'answer': sum.toString(),
      'generated': DateTime.now().toIso8601String(),
    };

    // Save the CAPTCHA state
    _prefs.setString(_captchaStateKey, jsonEncode(captchaState));

    return captchaState;
  }

  /// Verify a CAPTCHA response
  bool verifyCaptcha(String userAnswer) {
    String? savedStateJson = _prefs.getString(_captchaStateKey);
    if (savedStateJson == null) return false;

    try {
      Map<String, dynamic> savedState = jsonDecode(savedStateJson);
      return userAnswer == savedState['answer'];
    } catch (e) {
      debugPrint('Error verifying CAPTCHA: $e');
      return false;
    }
  }

  /// Clear CAPTCHA state after successful login
  Future<void> clearCaptchaState() async {
    await _prefs.remove(_captchaStateKey);
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatvan_kepenk/services/security_service.dart';

class AuthService {
  static const String _authKey = 'admin_auth';
  static const String _adminUsername = 'admin'; // Change this
  static const String _adminPassword = "X#9pT!v@L3k1qZw8&mN"; // Change this
  static const String _sessionStartKey = 'session_start_time';

  final SharedPreferences _prefs;
  late final SecurityService _securityService;

  AuthService(this._prefs) {
    _securityService = SecurityService(_prefs);
  }

  // Get reference to the security service
  SecurityService get securityService => _securityService;

  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    String? captchaAnswer,
  }) async {
    Map<String, dynamic> result = {
      'success': false,
      'message': '',
      'blocked': false,
      'blockTimeRemaining': 0,
      'requireCaptcha': false,
      'captchaState': null,
    };

    // First check if login is blocked due to too many attempts
    if (_securityService.isLoginBlocked()) {
      int remainingTime = _securityService.getRemainingBlockTime();
      result['blocked'] = true;
      result['blockTimeRemaining'] = remainingTime;
      result['message'] =
          'Too many failed login attempts. Please try again later.';
      return result;
    }

    // After 3 failed attempts, require CAPTCHA
    int attempts = _prefs.getInt('login_attempts') ?? 0;
    if (attempts >= 3) {
      // Require CAPTCHA validation
      if (captchaAnswer == null) {
        // No CAPTCHA answer provided but required
        result['requireCaptcha'] = true;
        result['captchaState'] = _securityService.generateCaptchaState();
        result['message'] = 'Please solve the CAPTCHA to continue';
        return result;
      } else {
        // CAPTCHA was provided, validate it
        if (!_securityService.verifyCaptcha(captchaAnswer)) {
          // Wrong CAPTCHA answer
          result['requireCaptcha'] = true;
          result['captchaState'] = _securityService.generateCaptchaState();
          result['message'] = 'Incorrect CAPTCHA. Please try again.';
          return result;
        }
        // CAPTCHA is valid, proceed with login
      }
    } // In a production app, we would hash the password and compare with stored hash
    // We're keeping this simple for the demo

    if (username == _adminUsername && password == _adminPassword) {
      // Successful login
      await _prefs.setBool(_authKey, true);

      // Record session start time
      await _prefs.setString(
        _sessionStartKey,
        DateTime.now().toIso8601String(),
      );

      // Reset security measures on successful login
      await _securityService.resetLoginAttempts();
      await _securityService.clearCaptchaState();
      await _securityService.updateLastActivity();

      result['success'] = true;
      result['message'] = 'Login successful';
      return result;
    }

    // Failed login attempt
    bool isBlocked = await _securityService.recordFailedLoginAttempt();
    if (isBlocked) {
      result['blocked'] = true;
      result['blockTimeRemaining'] = _securityService.getRemainingBlockTime();
      result['message'] =
          'Too many failed login attempts. Please try again later.';
    } else {
      attempts = _prefs.getInt('login_attempts') ?? 0;
      if (attempts >= 3) {
        result['requireCaptcha'] = true;
        result['captchaState'] = _securityService.generateCaptchaState();
        result['message'] =
            'Invalid credentials. Please solve the CAPTCHA to continue.';
      } else {
        result['message'] = 'Invalid username or password.';
      }
    }

    return result;
  }

  Future<void> logout() async {
    await _prefs.remove(_authKey);
    await _prefs.remove(_sessionStartKey);
    // Clear security related session data
    await _prefs.remove('last_activity_time');
  }

  bool isLoggedIn() {
    bool loggedIn = _prefs.getBool(_authKey) ?? false;

    // Check if session has timed out due to inactivity
    if (loggedIn && _securityService.hasSessionTimedOut()) {
      // Auto-logout and return false
      logout();
      return false;
    }

    return loggedIn;
  }

  // Update last activity timestamp to prevent session timeout
  Future<void> updateActivity() async {
    if (isLoggedIn()) {
      await _securityService.updateLastActivity();
    }
  }
}

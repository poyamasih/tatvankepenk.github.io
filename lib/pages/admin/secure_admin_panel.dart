import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/pages/admin/admin_panel_supabase.dart';
import 'package:tatvan_kepenk/services/auth_service.dart';
import 'package:tatvan_kepenk/widgets/session_activity_detector.dart';
import 'dart:async';

/// A wrapper that adds security features to the AdminPanelSupabase page
class SecureAdminPanel extends StatefulWidget {
  const SecureAdminPanel({Key? key}) : super(key: key);

  @override
  State<SecureAdminPanel> createState() => _SecureAdminPanelState();
}

class _SecureAdminPanelState extends State<SecureAdminPanel> {
  late AuthService _authService;
  bool _isInitialized = false;
  static const int _sessionTimeoutMinutes = 30;
  Timer? _sessionTimer;
  int _inactivitySeconds = 0;
  bool _showingTimeoutWarning = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _startSessionTimer();
  }

  Future<void> _initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _authService = AuthService(prefs);

    if (!_authService.isLoggedIn()) {
      Get.offAllNamed('/admin/login');
      return;
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _startSessionTimer() {
    // Cancel any existing timer
    _sessionTimer?.cancel();

    // Reset inactivity counter
    _inactivitySeconds = 0;

    // Start a new timer that checks every second
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _inactivitySeconds++;

        // Show warning when approaching timeout (2 minutes before)
        if (_inactivitySeconds >= (_sessionTimeoutMinutes * 60 - 120) &&
            !_showingTimeoutWarning) {
          _showTimeoutWarning();
        }

        // Auto-logout when session times out
        if (_inactivitySeconds >= _sessionTimeoutMinutes * 60) {
          _handleSessionTimeout();
        }
      });
    });
  }

  void _resetSessionTimer() {
    _inactivitySeconds = 0;
    _showingTimeoutWarning = false;

    // Also update last activity in AuthService
    _authService.updateActivity();
  }

  void _showTimeoutWarning() {
    _showingTimeoutWarning = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Oturum Zaman Aşımı Uyarısı'),
          content: const Text(
            'Oturumunuz 2 dakika içinde sona erecektir. Devam etmek istiyor musunuz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetSessionTimer();
              },
              child: const Text('Devam Et'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSessionTimeout();
              },
              child: const Text('Oturumu Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _handleSessionTimeout() {
    _sessionTimer?.cancel();
    _authService.logout();
    Get.offAllNamed('/admin/login');
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SessionActivityDetector(
      onActivityDetected: _resetSessionTimer,
      onInactivityTimeout: _handleSessionTimeout,
      inactivityDuration: Duration(minutes: _sessionTimeoutMinutes),
      child: const AdminPanelSupabase(),
    );
  }
}

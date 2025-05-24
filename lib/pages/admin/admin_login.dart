import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/widgets/animated_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatvan_kepenk/services/auth_service.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'dart:async';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _isLoading = false;
  bool _isTestingSupabase = false;
  String _errorMessage = '';
  String _supabaseStatus = '';
  late AuthService _authService;
  late SharedPreferences _prefs;

  // Security related states
  bool _isLoginBlocked = false;
  int _blockTimeRemaining = 0;
  bool _requireCaptcha = false;
  Map<String, dynamic>? _captchaState;
  Timer? _blockTimeTimer;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _prefs = await SharedPreferences.getInstance();
    _authService = AuthService(_prefs);

    // Check if the user is already logged in
    if (_authService.isLoggedIn()) {
      Get.offNamed('/admin/panel');
      return;
    }

    // Check if login is currently blocked
    _checkLoginBlockStatus();
  }

  void _checkLoginBlockStatus() {
    if (_authService.securityService.isLoginBlocked()) {
      setState(() {
        _isLoginBlocked = true;
        _blockTimeRemaining =
            _authService.securityService.getRemainingBlockTime();
      });

      // Setup timer to update remaining time
      _blockTimeTimer?.cancel();
      _blockTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          _blockTimeRemaining =
              _authService.securityService.getRemainingBlockTime();
          if (_blockTimeRemaining <= 0) {
            _isLoginBlocked = false;
            _blockTimeTimer?.cancel();
          }
        });
      });
    } else {
      setState(() {
        _isLoginBlocked = false;
      });
    }

    // Check if CAPTCHA is required based on previous attempts
    int attempts = _prefs.getInt('login_attempts') ?? 0;
    if (attempts >= 3) {
      setState(() {
        _requireCaptcha = true;
        _captchaState = _authService.securityService.generateCaptchaState();
      });
    }
  }

  Future<void> _testSupabaseConnection() async {
    setState(() {
      _isTestingSupabase = true;
      _supabaseStatus = 'در حال تست اتصال به Supabase...';
    });

    try {
      final supabaseService = SupabaseService();
      await supabaseService.initialize();

      // یک کوئری ساده برای تست اتصال
      await supabaseService.client.from('home_content').select('id').limit(1);

      setState(() {
        _supabaseStatus = 'اتصال به Supabase با موفقیت برقرار شد! ✓';
      });
    } catch (e) {
      setState(() {
        _supabaseStatus = 'خطا در اتصال به Supabase: $e';
      });
      print('Supabase connection error: $e');
    } finally {
      setState(() {
        _isTestingSupabase = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      String? captchaAnswer = _requireCaptcha ? _captchaController.text : null;

      // Call the enhanced login method
      Map<String, dynamic> result = await _authService.login(
        username,
        password,
        captchaAnswer: captchaAnswer,
      );

      if (result['success']) {
        // Successful login
        Get.offNamed('/admin/panel');
      } else {
        setState(() {
          _errorMessage = result['message'];

          // Update security-related UI states
          _isLoginBlocked = result['blocked'] ?? false;
          _blockTimeRemaining = result['blockTimeRemaining'] ?? 0;
          _requireCaptcha = result['requireCaptcha'] ?? false;

          if (result['captchaState'] != null) {
            _captchaState = result['captchaState'];
            _captchaController.clear(); // Clear previous captcha input
          }

          // If login is blocked, start timer to update remaining time
          if (_isLoginBlocked) {
            _blockTimeTimer?.cancel();
            _blockTimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
              setState(() {
                _blockTimeRemaining =
                    _authService.securityService.getRemainingBlockTime();
                if (_blockTimeRemaining <= 0) {
                  _isLoginBlocked = false;
                  _blockTimeTimer?.cancel();
                }
              });
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error occurred. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatBlockTimeRemaining() {
    int minutes = _blockTimeRemaining ~/ 60;
    int seconds = _blockTimeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 30),
                  const Text(
                    'Yönetici Girişi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login blocked warning
                  if (_isLoginBlocked) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Too many failed login attempts',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again in ${_formatBlockTimeRemaining()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    // Normal login form when not blocked
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kullanıcı Adı',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                    // CAPTCHA verification if required
                    if (_requireCaptcha && _captchaState != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Security Verification',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Please solve: ${_captchaState!['question']}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _captchaController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter answer',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child:
                            _isLoading
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Giriş Yap',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // دکمه تست اتصال به Supabase
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed:
                          _isTestingSupabase ? null : _testSupabaseConnection,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      icon:
                          _isTestingSupabase
                              ? SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Icon(
                                Icons.cloud,
                                color: Colors.white.withOpacity(0.7),
                              ),
                      label: Text(
                        'تست اتصال Supabase',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  // نمایش وضعیت اتصال به Supabase
                  if (_supabaseStatus.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            _supabaseStatus.contains('موفقیت')
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _supabaseStatus.contains('موفقیت')
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _supabaseStatus,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _blockTimeTimer?.cancel();
    super.dispose();
  }
}

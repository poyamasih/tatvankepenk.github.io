import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/pages/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  bool _assetsLoaded = false;
  bool _hasNavigated = false;

  Future<void> _preloadAssets(BuildContext context) async {
    try {
      await Future.wait([
        precacheImage(
          const AssetImage('assets/images/bg_dark_stars.png'),
          context,
        ),
        precacheImage(const AssetImage('assets/images/logo.png'), context),
        precacheImage(
          const AssetImage('assets/images/Automatic_Shutter.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/Autumatik_rof.png'),
          context,
        ),
        // Ensure minimum display time for splash screen
        Future.delayed(const Duration(milliseconds: 2000)),
      ]);

      if (mounted) {
        setState(() => _assetsLoaded = true);
        _tryNavigateToHome();
      }
    } catch (e) {
      print('Error preloading assets: $e');
      // If asset loading fails, still allow navigation after a delay
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        setState(() => _assetsLoaded = true);
        _tryNavigateToHome();
      }
    }
  }

  void _tryNavigateToHome() {
    if (!mounted || _hasNavigated) return;

    if (_assetsLoaded && _controller.status == AnimationStatus.completed) {
      _hasNavigated = true;

      // اضافه کردن تایمر برای جلوگیری از مسدود شدن UI
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.off(
          () => const HomePage(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Start animation and preloading assets simultaneously
    _controller.forward().then((_) => _tryNavigateToHome());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAssets(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_dark_stars.png',
            fit: BoxFit.cover,
            cacheWidth: MediaQuery.of(context).size.width.round(),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder:
                  (_, __) => Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 180,
                          height: 180,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

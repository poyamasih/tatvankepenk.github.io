// filepath: c:\flutter procekts\tatvan_kepenk\lib\widgets\header.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/pages/loading.dart';
import 'package:tatvan_kepenk/pages/login_page.dart';

class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  void goToNextPageWithLoading(BuildContext context) async {
    // نمایش لودینگ
    Get.dialog(const LoadingScreen(), barrierDismissible: false);

    // شبیه‌سازی تأخیر یا عملیات async مثل fetch
    await Future.delayed(const Duration(seconds: 2));

    // بستن لودینگ
    Get.back();

    // رفتن به صفحه جدید
    Get.to(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    // رنگ بک‌گراند اصلی سایت
    final Color mainBackground = const Color(0xFF0A0A1A);

    // Check if the screen is small
    final bool isSmallScreen = MediaQuery.of(context).size.width < 800;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(color: Colors.transparent),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // درخشش سمت راست و محو شدن به سمت چپ
              Positioned.fill(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Colors.white, Color.fromARGB(0, 233, 233, 233)],
                      stops: [0.0, 0.3],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainBackground.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(60),
                      ),
                      border: const Border(
                        right: BorderSide(color: Colors.white24, width: 0.2),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white24,
                          offset: Offset(2, 0),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // افکت شیشه‌ای
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width / 200,
                top: 0,
                child: Image.asset("assets/images/logo.png", width: 100),
              ),

              // محتوای هدر - مخفی کردن منو در صفحات کوچک و نمایش دکمه همبرگر
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    // Show either menu items or hamburger button based on screen size
                    if (isSmallScreen)
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          // Open the drawer when the button is pressed
                          Scaffold.of(context).openDrawer();
                        },
                      )
                    else ...[
                      const _NavItem(title: 'Ana Sayfa'),
                      const _NavItem(title: 'Anakayıak'),
                      const _NavItem(title: 'Hakkımızda'),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          child: const Text(
                            'İletişim',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Drawer widget for small screens
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Main background color
    final Color mainBackground = const Color(0xFF0A0A1A);

    return ClipRRect(
      // Rounded corners on the right side
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: Drawer(
        width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
        backgroundColor:
            Colors.transparent, // Transparent background for glass effect
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                mainBackground.withOpacity(0.9),
                mainBackground.withOpacity(0.8),
              ],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ), // Strong blur for glass effect
            child: Column(
              children: [
                // Custom drawer header with glossy effect
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Glass accent in the background
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Logo
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/logo.png", width: 120),
                            const SizedBox(height: 12),
                            Container(
                              height: 3,
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white70,
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu items with animation
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildAnimatedMenuItem(
                        context: context,
                        icon: Icons.home_outlined,
                        title: 'Ana Sayfa',
                        index: 0,
                      ),
                      _buildDivider(),
                      _buildAnimatedMenuItem(
                        context: context,
                        icon: Icons.computer,
                        title: 'Anakayıak',
                        index: 1,
                      ),
                      _buildDivider(),
                      _buildAnimatedMenuItem(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'Hakkımızda',
                        index: 2,
                      ),
                      _buildDivider(),
                      _buildAnimatedMenuItem(
                        context: context,
                        icon: Icons.mail_outline,
                        title: 'İletişim',
                        index: 3,
                      ),
                      _buildDivider(),
                      // Social Media Section
                      _buildSocialMediaSection(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a divider
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.01),
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.01),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build animated menu items
  Widget _buildAnimatedMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 300 + (index * 100),
      ), // Staggered animation
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset((-20 * (1 - value)), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: () {
          // Add navigation logic here
          Navigator.pop(context);
        },
      ),
    );
  }

  // Social media section
  Widget _buildSocialMediaSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bizi Takip Edin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSocialIcon(Icons.facebook, () {}),
              _buildSocialIcon(Icons.telegram, () {}),
              _buildSocialIcon(Icons.whatshot, () {}),
              _buildSocialIcon(Icons.language, () {}),
            ],
          ),
        ],
      ),
    );
  }

  // Social media icon
  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  const _NavItem({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () {},
        child: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

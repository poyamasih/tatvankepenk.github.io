import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:tatvan_kepenk/widgets/hiroselection.dart';

class ResponsiveHomeContent extends StatelessWidget {
  final int currentPageIndex;
  final bool showScrollHint;

  const ResponsiveHomeContent({
    Key? key,
    required this.currentPageIndex,
    this.showScrollHint = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 800;
    final isMediumScreen = screenWidth >= 800 && screenWidth < 1200;
    final isLargeScreen = screenWidth >= 1200;

    // Responsive values
    final topPadding =
        isSmallScreen
            ? screenHeight * 0.05
            : isMediumScreen
            ? screenHeight * 0.08
            : screenHeight * 0.1;

    final circleScale =
        isSmallScreen
            ? 0.7
            : isMediumScreen
            ? 1.0
            : 1.2;

    // Build feature item method
    Widget buildFeatureItem({
      required IconData icon,
      required String title,
      int delay = 0,
    }) {
      // Responsive sizing
      final iconSize =
          isSmallScreen
              ? 28.0
              : isLargeScreen
              ? 36.0
              : 32.0;
      final fontSize =
          isSmallScreen
              ? 12.0
              : isLargeScreen
              ? 16.0
              : 14.0;
      final padding =
          isSmallScreen
              ? 12.0
              : isLargeScreen
              ? 20.0
              : 16.0;

      return Container(
        width: isSmallScreen ? double.infinity : null,
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 0 : 8,
          vertical: isSmallScreen ? 8 : 0,
        ),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 800 + delay),
          curve: Curves.easeOutQuint,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: iconSize),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.fromLTRB(0, topPadding, 0, 20),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Decorative gradient circles in background with responsive sizing
              Positioned(
                top: isSmallScreen ? -30 : -50,
                right: isSmallScreen ? -10 : -20,
                child: Container(
                  width: 200 * circleScale,
                  height: 200 * circleScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.2,
                left: isSmallScreen ? -40 : -80,
                child: Container(
                  width: 300 * circleScale,
                  height: 300 * circleScale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Content wrapped in SingleChildScrollView for small screens
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (topPadding + 20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Logo with animation (if available)
                      if (isLargeScreen || isMediumScreen) ...[
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutQuint,
                          margin: EdgeInsets.only(top: screenHeight * 0.02),
                          height: 60,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Main Hero Content
                      const HeroSection(),

                      SizedBox(height: isSmallScreen ? 20 : 30),

                      // Feature highlights - responsive layout
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal:
                              isSmallScreen
                                  ? 20
                                  : isLargeScreen
                                  ? screenWidth * 0.1
                                  : screenWidth * 0.05,
                        ),
                        child:
                            isSmallScreen
                                ? Column(
                                  children: [
                                    buildFeatureItem(
                                      icon: Icons.security_rounded,
                                      title: "Güçlü Güvenlik",
                                      delay: 100,
                                    ),
                                    buildFeatureItem(
                                      icon: Icons.timer,
                                      title: "Uzun Ömürlü",
                                      delay: 300,
                                    ),
                                    buildFeatureItem(
                                      icon: Icons.design_services_rounded,
                                      title: "Modern Tasarım",
                                      delay: 500,
                                    ),
                                  ],
                                )
                                : Row(
                                  children: [
                                    Expanded(
                                      child: buildFeatureItem(
                                        icon: Icons.security_rounded,
                                        title: "Güçlü Güvenlik",
                                        delay: 100,
                                      ),
                                    ),
                                    Expanded(
                                      child: buildFeatureItem(
                                        icon: Icons.timer,
                                        title: "Uzun Ömürlü",
                                        delay: 300,
                                      ),
                                    ),
                                    Expanded(
                                      child: buildFeatureItem(
                                        icon: Icons.design_services_rounded,
                                        title: "Modern Tasarım",
                                        delay: 500,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

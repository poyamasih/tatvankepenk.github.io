import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tatvan_kepenk/widgets/frostedglass.dart';

class HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen
    final bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    final screenWidth = MediaQuery.of(context).size.width;

    // For text sizing based on screen width
    final double titleFontSize =
        isSmallScreen
            ? screenWidth /
                12 // Larger on mobile relative to screen
            : screenWidth / 15; // Original size for desktop

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 0),
      child:
          isSmallScreen
              // Use Column for mobile layout
              ? Column(
                children: [
                  // Text section for mobile
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [
                                Color.fromARGB(
                                  255,
                                  207,
                                  207,
                                  207,
                                ), // نقره‌ای روشن
                                Color(0xFFBEBEBE), // خاکستری نقره‌ای
                                Color.fromARGB(255, 88, 88, 88), // سفید
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                        child: Text(
                          'Otomatik Kepenk ve\nEndüstriyel\nKapı Sistemleri',
                          textAlign:
                              isSmallScreen
                                  ? TextAlign.center
                                  : TextAlign.start,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Services button
                      Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onDoubleTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      160,
                                      160,
                                      160,
                                    ).withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                    spreadRadius: -5,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(-5, -5),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: FrostedGlassBox(
                                theWidth: 180, // Wider button on mobile
                                theHeight: 50,
                                theChild: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Hizmetlerimiz",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.white54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Image section for mobile
                  Container(
                    height: screenWidth * 0.5, // Responsive height
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Glass Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: screenWidth * 0.7,
                                height: screenWidth * 0.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                          ),

                          // Positioned image, centered on mobile
                          Positioned(
                            top: 3,
                            child: Image.asset(
                              'assets/images/Automatic_Shutter.png',
                              width: screenWidth * 0.6,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
              // Use Row for desktop layout
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Text section for desktop
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (bounds) => const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 207, 207, 207),
                                  Color(0xFFBEBEBE),
                                  Color.fromARGB(255, 88, 88, 88),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                          child: Text(
                            'Otomatik Kepenk ve\nEndüstriyel\nKapı Sistemleri',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onDoubleTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      160,
                                      160,
                                      160,
                                    ).withOpacity(0.5),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                    spreadRadius: -5,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(-5, -5),
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: FrostedGlassBox(
                                theWidth: 150,
                                theHeight: 50,
                                theChild: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Hizmetlerimiz",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 15,
                                        color: Colors.white54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 40),

                  // Right: Image section for desktop
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Glass Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: screenWidth / 3.9,
                                height: screenWidth / 3.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                            ),
                          ),

                          // Positioned image for desktop
                          Positioned(
                            top: 3,
                            left: -60,
                            child: Image.asset(
                              'assets/images/Automatic_Shutter.png',
                              width: screenWidth / 3,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tatvan_kepenk/widgets/frostedglass.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});
  @override
  Widget build(BuildContext context) {
    // Check if we're on a small screen
    final bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define font size based on screen width
    final double titleFontSize =
        isSmallScreen ? screenWidth / 20 : screenWidth / 15;

    return Container(
      width: double.infinity,
      child:
          isSmallScreen
              // Use Column for mobile layout
              ? Column(
                children: [
                  // Top: Text section for mobile
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
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // تطبیق با FrostedGlassBox
                          onDoubleTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                // سایه‌ی اصلی زیرین (برجسته‌کننده)
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    160,
                                    160,
                                    160,
                                  ).withOpacity(0.5), // کمی پررنگ‌تر از قبل
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                  spreadRadius:
                                      -5, // با این مقدار سایه به بیرون گسترش می‌یابد
                                ),

                                // سایه روشن از بالا برای حس برجستگی
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
                                  crossAxisAlignment: CrossAxisAlignment.center,

                                  children: [
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

                  const SizedBox(height: 40),

                  // Image section for mobile
                  Center(
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
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width * 0.6,
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

                        // Image
                        Positioned(
                          top: 3,
                          left: -20,
                          child: Image.asset(
                            'assets/images/Automatic_Shutter.png',
                            width: MediaQuery.of(context).size.width * 0.8,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Row(
                children: [
                  Column(
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
                        child: FrostedGlassBox(
                          theWidth: 150,
                          theHeight: 50,
                          theChild: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
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
                    ],
                  ),
                  const SizedBox(width: 40),

                  // سمت راست: تصویر درب اتوماتیک با نور
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Glass Container (شیشه‌ای)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                width: MediaQuery.of(context).size.width / 3.9,
                                height: MediaQuery.of(context).size.width / 3.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white, // گرادینت سفید از بالا
                                      Colors.white, // محو شدن به پایین
                                      Colors.transparent, // انتهای شیشه‌ای
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  color: Colors.white.withOpacity(
                                    0.05,
                                  ), // پایه‌ی شیشه‌ای
                                ),
                              ),
                            ),
                          ),

                          // تصویر درب که کمی از باکس بیرون می‌زنه
                          Positioned(
                            top: 3,

                            left: -60,
                            child: Image.asset(
                              'assets/images/Automatic_Shutter.png',
                              width: MediaQuery.of(context).size.width / 3,
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

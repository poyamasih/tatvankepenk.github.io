import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class FrostedGlassBox extends StatelessWidget {
  const FrostedGlassBox({
    Key? key,
    required this.theWidth,
    required this.theHeight,
    required this.theChild,
  }) : super(key: key);
  final theWidth;
  final theHeight;
  final theChild;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: theWidth,
        height: theHeight,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            // سایه‌ی اصلی زیرین (برجسته‌کننده)
            BoxShadow(
              color: const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withOpacity(0.5), // کمی پررنگ‌تر از قبل
              blurRadius: 40,
              offset: const Offset(0, 25),
              spreadRadius: -5, // با این مقدار سایه به بیرون گسترش می‌یابد
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
        child: Stack(
          children: [
            // تاری بک‌گراند
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
              child: Container(),
            ),

            // لایه‌ی نیمه شفاف شیشه‌ای
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.13)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
            ),

            // محتوا
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: theChild,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScrollIndicator extends StatelessWidget {
  final bool isVisible;
  final double size;
  final Color color;
  final double opacity;

  const ScrollIndicator({
    Key? key,
    this.isVisible = true,
    this.size = 50.0,
    this.color = Colors.white,
    this.opacity = 0.8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox();
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: Icon(
            Icons.keyboard_arrow_right_rounded,
            color: color.withOpacity(opacity),
            size: size * 0.6,
          )
          .animate(onPlay: (controller) => controller.repeat())
          .slideX(
            begin: -0.2,
            end: 0.2,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          )
          .fadeIn(duration: const Duration(milliseconds: 400))
          .then()
          .slideX(
            begin: 0.2,
            end: -0.2,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          ),
    );
  }
}

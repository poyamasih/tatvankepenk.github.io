import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slower animation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      // Add RepaintBoundary for better performance
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A1A),
                  Color(0xFF141432),
                  Color(0xFF0A0A1A),
                ],
              ),
            ),
          ),

          // Background image for texture with optimized opacity animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 0.8 + 0.2 * math.sin(_controller.value * math.pi * 2),
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/bg_dark_stars.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  AnimatedBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.0
          ..color = Colors.white.withOpacity(0.07);

    final width = size.width;
    final height = size.height;

    // Draw subtle horizontal lines
    for (int i = 0; i < 10; i++) {
      final yPosition = height * (0.1 + i * 0.09);
      final path = Path();
      path.moveTo(0, yPosition);

      for (double x = 0; x <= width; x += 2) {
        final normalizedX = x / width;
        final wavePhase = animationValue * 2 * math.pi;
        final y =
            yPosition +
            math.sin(normalizedX * 8 * math.pi + wavePhase) * 2 +
            math.sin(normalizedX * 4 * math.pi + wavePhase * 1.5) * 3;

        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }

    // Draw light spots
    final spotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final xPos = width * (0.1 + i * 0.2);
      final yPos = height * (0.2 + (i % 3) * 0.25);
      final radius =
          50 + ((math.sin(animationValue * math.pi * 2 + i) + 1) * 30);

      final gradient = RadialGradient(
        colors: [
          Colors.blue.withOpacity(
            0.03 * (1 + math.sin(animationValue * math.pi * 2)),
          ),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(xPos, yPos), radius: radius),
      );

      spotPaint.shader = gradient;
      canvas.drawCircle(Offset(xPos, yPos), radius, spotPaint);
    }
  }

  @override
  bool shouldRepaint(AnimatedBackgroundPainter oldDelegate) => true;
}

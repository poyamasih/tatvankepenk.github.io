import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class FuturisticIntroSection extends StatefulWidget {
  const FuturisticIntroSection({Key? key}) : super(key: key);

  @override
  State<FuturisticIntroSection> createState() => _FuturisticIntroSectionState();
}

class _FuturisticIntroSectionState extends State<FuturisticIntroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  late List<LightStream> _lightStreams;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize particles
    _particles = List.generate(
      60,
      (index) => Particle(
        position: Offset(
          math.Random().nextDouble() * 1.2,
          math.Random().nextDouble(),
        ),
        size: math.Random().nextDouble() * 4 + 1,
        speed: math.Random().nextDouble() * 0.02 + 0.01,
        opacity: math.Random().nextDouble() * 0.6 + 0.2,
      ),
    );

    // Initialize light streams
    _lightStreams = List.generate(
      15,
      (index) => LightStream(
        start: Offset(math.Random().nextDouble(), math.Random().nextDouble()),
        length: math.Random().nextDouble() * 0.5 + 0.3,
        angle: math.Random().nextDouble() * math.pi,
        speed: math.Random().nextDouble() * 0.002 + 0.001,
        color:
            HSLColor.fromAHSL(
              math.Random().nextDouble() * 0.5 + 0.5,
              math.Random().nextDouble() * 360,
              math.Random().nextDouble() * 0.3 + 0.7,
              math.Random().nextDouble() * 0.5 + 0.5,
            ).toColor(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 800;
    final textSize = isSmallScreen ? 32.0 : 48.0;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Black background with deep gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A1A),
                  const Color(0xFF141432),
                  const Color(0xFF0A0A1A),
                ],
              ),
            ),
          ),

          // Animated particles and light streams
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: FuturisticBackgroundPainter(
                  particles: _particles,
                  lightStreams: _lightStreams,
                  animationValue: _controller.value,
                ),
                size: Size(screenWidth, screenHeight),
              );
            },
          ),

          // Asymmetric spotlight in the center
          Positioned.fill(
            child: Center(
              child: Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.6,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                    stops: const [0.2, 1.0],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
          ),

          // Decorative fluid shape behind text - top
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.1,
            child: _buildFluidShape(
              width: screenWidth * 0.8,
              height: screenHeight * 0.3,
              color1: Color(0xFF2A2A5A).withOpacity(0.3),
              color2: Color(0xFF1A1A4A).withOpacity(0.1),
            ),
          ),

          // Decorative fluid shape behind text - bottom
          Positioned(
            bottom: screenHeight * 0.25,
            right: screenWidth * 0.15,
            child: _buildFluidShape(
              width: screenWidth * 0.7,
              height: screenHeight * 0.2,
              color1: Color(0xFF3A3A6A).withOpacity(0.2),
              color2: Color(0xFF2A2A5A).withOpacity(0.1),
              isVerticalFlip: true,
              isHorizontalFlip: true,
            ),
          ),

          // Parallax depth layers with 3D effect
          _buildParallaxLayer(
            screenWidth * 0.6,
            screenHeight * 0.4,
            Offset(-20, -10),
            0.8,
          ),
          _buildParallaxLayer(
            screenWidth * 0.5,
            screenHeight * 0.3,
            Offset(40, 30),
            0.6,
          ),

          // Central content container with frosted glass effect
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Electronic wave pattern animation
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ElectronicWavePainter(
                          waveCount: 3,
                          amplitude: 5.0,
                          frequency: 10.0,
                          phase: _controller.value * math.pi * 2,
                        ),
                      );
                    },
                  ),
                ), // Floating Product Image
                Positioned(
                  top: isSmallScreen ? -100 : -120,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1.0 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final floatValue =
                            math.sin(_controller.value * math.pi * 2) * 5;
                        return Transform.translate(
                          offset: Offset(0, floatValue),
                          child: Container(
                            width: screenWidth * (isSmallScreen ? 0.6 : 0.4),
                            height: screenHeight * 0.25,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/Automatic_Shutter.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ), // Simplified elegant container for text
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: screenWidth * (isSmallScreen ? 0.9 : 0.65),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Clean title with subtle effect
                          Text(
                            'TATVAN KEPENK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.0,
                              height: 1.2,
                              fontFamily: 'Roboto',
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Product-focused tagline
                          Text(
                            'OTOMATİK KEPENK VE ENDÜSTRİYEL KAPI SİSTEMLERİ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: textSize * 0.33,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Business value proposition
                          Text(
                            'Güvenlik, Dayanıklılık ve Modern Tasarım',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: textSize * 0.4,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 1.0,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Simplified feature icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSimplifiedFeatureItem(
                                Icons.security,
                                "Güvenlik",
                              ),
                              const SizedBox(width: 40),
                              _buildSimplifiedFeatureItem(
                                Icons.engineering,
                                "Profesyonellik",
                              ),
                              const SizedBox(width: 40),
                              _buildSimplifiedFeatureItem(
                                Icons.design_services,
                                "Tasarım",
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Call-to-action button with clean design
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 20 : 30,
                                vertical: isSmallScreen ? 12 : 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'ÜRÜNLERİMİZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Creates animated fluid shapes for background decoration
  Widget _buildFluidShape({
    required double width,
    required double height,
    required Color color1,
    required Color color2,
    bool isVerticalFlip = false,
    bool isHorizontalFlip = false,
  }) {
    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..scale(isHorizontalFlip ? -1.0 : 1.0, isVerticalFlip ? -1.0 : 1.0),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double phase = _controller.value * math.pi * 2;
          return CustomPaint(
            size: Size(width, height),
            painter: FluidShapePainter(
              color1: color1,
              color2: color2,
              phase: phase,
            ),
          );
        },
      ),
    );
  }

  // Creates parallax layer for 3D depth effect
  Widget _buildParallaxLayer(
    double width,
    double height,
    Offset offset,
    double opacity,
  ) {
    return Positioned(
      top: offset.dy + (height * 0.5),
      left: offset.dx + (width * 0.1),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final sinValue = math.sin(_controller.value * math.pi * 2);
          final cosValue = math.cos(_controller.value * math.pi * 2);

          return Transform.translate(
            offset: Offset(sinValue * 10, cosValue * 5),
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withOpacity(0.05 * opacity),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build simplified feature item with minimal design
  Widget _buildSimplifiedFeatureItem(IconData icon, String title) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    final iconSize = isSmallScreen ? 24.0 : 28.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.9),
            size: iconSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: fontSize,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// Custom clipper for asymmetric shape
class AsymmetricBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Create an asymmetric shape with organic curves
    path.moveTo(0.3 * w, 0);
    path.quadraticBezierTo(0.1 * w, 0.2 * h, 0, 0.4 * h);
    path.lineTo(0, 0.7 * h);
    path.quadraticBezierTo(0.1 * w, 0.9 * h, 0.3 * w, h);
    path.lineTo(0.7 * w, h);
    path.quadraticBezierTo(0.9 * w, 0.8 * h, w, 0.6 * h);
    path.lineTo(w, 0.3 * h);
    path.quadraticBezierTo(0.9 * w, 0.1 * h, 0.7 * w, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Particle class for floating particle effect
class Particle {
  Offset position;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Light stream class for light ray effect
class LightStream {
  Offset start;
  double length;
  double angle;
  double speed;
  Color color;

  LightStream({
    required this.start,
    required this.length,
    required this.angle,
    required this.speed,
    required this.color,
  });
}

// Custom painter for background particles and light rays
class FuturisticBackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final List<LightStream> lightStreams;
  final double animationValue;

  FuturisticBackgroundPainter({
    required this.particles,
    required this.lightStreams,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round;

    // Draw particles
    for (var particle in particles) {
      // Update particle position with animation
      final yPos =
          (particle.position.dy + animationValue * particle.speed) % 1.0;
      final offset = Offset(
        particle.position.dx * size.width,
        yPos * size.height,
      );

      // Create pulsing effect for particles
      final pulsingOpacity =
          particle.opacity *
          (0.7 +
              0.3 *
                  math.sin(
                    animationValue * math.pi * 2 + particle.position.dx * 10,
                  ));

      paint.color = Colors.white.withOpacity(pulsingOpacity);
      canvas.drawCircle(offset, particle.size, paint);
    }

    // Draw light streams
    for (var stream in lightStreams) {
      // Update stream position with animation
      final movingAngle =
          stream.angle + animationValue * stream.speed * math.pi * 2;
      final start = Offset(
        stream.start.dx * size.width,
        stream.start.dy * size.height,
      );

      final end = Offset(
        start.dx + math.cos(movingAngle) * stream.length * size.width,
        start.dy + math.sin(movingAngle) * stream.length * size.height,
      );

      // Create gradient for light stream
      final gradient = LinearGradient(
        colors: [stream.color.withOpacity(0.7), stream.color.withOpacity(0)],
      ).createShader(Rect.fromPoints(start, end));

      paint
        ..shader = gradient
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(FuturisticBackgroundPainter oldDelegate) => true;
}

// Custom painter for electronic wave pattern
class ElectronicWavePainter extends CustomPainter {
  final int waveCount;
  final double amplitude;
  final double frequency;
  final double phase;

  ElectronicWavePainter({
    required this.waveCount,
    required this.amplitude,
    required this.frequency,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final wavePhase = phase + (i * math.pi / waveCount);
      final verticalOffset = size.height * (0.3 + i * 0.2);

      path.moveTo(0, verticalOffset);

      for (double x = 0; x <= size.width; x++) {
        final normalizedX = x / size.width;
        final y =
            verticalOffset +
            amplitude *
                math.sin(normalizedX * frequency * math.pi + wavePhase) +
            amplitude *
                math.sin(
                  normalizedX * frequency * math.pi * 3 + wavePhase * 1.5,
                ) *
                0.3;

        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ElectronicWavePainter oldDelegate) => true;
}

// Custom painter for fluid animated shapes
class FluidShapePainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double phase;

  FluidShapePainter({
    required this.color1,
    required this.color2,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create a fluid, organic shape with math.sin and math.cos functions
    path.moveTo(0, height * 0.5);

    for (double x = 0; x <= width; x++) {
      final normalizedX = x / width;

      // Combine multiple sine waves for organic feel
      final y =
          height * 0.5 +
          height * 0.4 * math.sin(normalizedX * math.pi * 2 + phase) +
          height * 0.1 * math.sin(normalizedX * math.pi * 6 + phase * 2);

      path.lineTo(x, y);
    }

    // Complete the path
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // Create gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
    ).createShader(Rect.fromLTWH(0, 0, width, height));

    final paint =
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FluidShapePainter oldDelegate) =>
      oldDelegate.phase != phase ||
      oldDelegate.color1 != color1 ||
      oldDelegate.color2 != color2;
}

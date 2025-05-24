import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/content_storage.dart';

class SimplifiedIntroSection extends StatefulWidget {
  const SimplifiedIntroSection({Key? key}) : super(key: key);

  @override
  State<SimplifiedIntroSection> createState() => _SimplifiedIntroSectionState();
}

class _SimplifiedIntroSectionState extends State<SimplifiedIntroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  late ContentStorage _contentStorage;
  String _title = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _contentStorage = Get.find<ContentStorage>();
    _loadContent();
  }

  void _loadContent() {
    _title = _contentStorage.getHomeTitle();
    _description = _contentStorage.getHomeDescription();
    if (mounted) {
      setState(() {});
    }
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
          // Background gradient
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

          // Subtle background animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: SimplifiedBackgroundPainter(
                  animationValue: _controller.value,
                ),
                size: Size(screenWidth, screenHeight),
              );
            },
          ), // Center spotlight
          Positioned.fill(
            child: Center(
              child: Container(
                width: screenWidth * 0.7,
                height: screenHeight * 0.5,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.07),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 1.0],
                    radius: 0.8,
                  ),
                ),
              ),
            ),
          ), // Fixed Position Product Image with Hover Effect
          Positioned(
            top: 60, // Fixed top position
            right:
                isSmallScreen
                    ? 20
                    : screenWidth * 0.1, // Adjusted right position
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Smoother floating animation
                  final floatValue = math.sin(_controller.value * math.pi) * 2;

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 1.0,
                      end: _isHovered ? 1.05 : 1.0,
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Transform.translate(
                          offset: Offset(0, floatValue + (_isHovered ? -2 : 0)),
                          child: Container(
                            width: isSmallScreen ? 200 : 300, // Fixed width
                            height: isSmallScreen ? 200 : 300, // Fixed height
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                // Ambient shadow
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 5),
                                ),
                                // Hover glow effect
                                if (_isHovered)
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 2,
                                  ),
                              ],
                            ),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: _isHovered ? 1 : 0,
                              ),
                              duration: const Duration(milliseconds: 300),
                              builder: (context, value, child) {
                                return Transform.rotate(
                                  angle:
                                      (math.pi / 180) *
                                      (value * 2), // Subtle rotation on hover
                                  child: Image.asset(
                                    'assets/images/Automatic_Shutter.png',
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Main content container
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.7,
                    maxWidth: screenWidth * (isSmallScreen ? 0.9 : 0.7),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with premium font
                          Text(
                            _title.isNotEmpty ? _title : 'TATVAN KEPENK',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                fontSize:
                                    isSmallScreen ? textSize * 0.8 : textSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3.0,
                                height: 1.1,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Product tagline with elegant font
                          Text(
                            'OTOMATİK KEPENK VE ENDÜSTRİYEL KAPI SİSTEMLERİ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.raleway(
                              textStyle: TextStyle(
                                fontSize:
                                    isSmallScreen
                                        ? textSize * 0.28
                                        : textSize * 0.33,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.8,
                                height: 1.3,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Business value proposition with modern font
                          Text(
                            _description.isNotEmpty
                                ? _description
                                : 'Güvenlik, Dayanıklılık ve Modern Tasarım',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize:
                                    isSmallScreen
                                        ? textSize * 0.35
                                        : textSize * 0.4,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 0.5,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Feature icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFeatureItem(Icons.security, "Güvenlik"),
                              SizedBox(width: isSmallScreen ? 20 : 40),
                              _buildFeatureItem(
                                Icons.engineering,
                                "Profesyonellik",
                              ),
                              SizedBox(width: isSmallScreen ? 20 : 40),
                              _buildFeatureItem(
                                Icons.design_services,
                                "Tasarım",
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Call-to-action button
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 22 : 32,
                                vertical: isSmallScreen ? 14 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              elevation: 0,
                              shadowColor: Colors.black.withOpacity(0.3),
                            ),
                            child: Text(
                              'ÜRÜNLERİMİZ',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
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
    );
  }

  // Simple feature item widget
  Widget _buildFeatureItem(IconData icon, String title) {
    final isSmallScreen = MediaQuery.of(context).size.width < 800;
    final iconSize = isSmallScreen ? 22.0 : 26.0;
    final fontSize = isSmallScreen ? 12.0 : 14.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
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
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for simplified background
class SimplifiedBackgroundPainter extends CustomPainter {
  final double animationValue;

  SimplifiedBackgroundPainter({required this.animationValue});

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

    // Draw a few light spots
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
  bool shouldRepaint(SimplifiedBackgroundPainter oldDelegate) => true;
}

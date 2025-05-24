import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class EnhancedHeader extends StatefulWidget {
  final int currentPageIndex;
  final Function(int)? onPageChanged;

  const EnhancedHeader({
    super.key,
    this.currentPageIndex = 0,
    this.onPageChanged,
  });

  @override
  State<EnhancedHeader> createState() => _EnhancedHeaderState();
}

class _EnhancedHeaderState extends State<EnhancedHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isHovered = false;
  int get _currentPage => widget.currentPageIndex;

  final List<String> _pageNames = [
    'Ana Sayfa',
    'Kepenk Sistemleri',
    'Endüstriyel Kapılar',
    'Hakkımızda',
    'İletişim',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePageTap(int index) {
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: isSmallScreen ? 70 : 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.2),
              blurRadius: _isHovered ? 20 : 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background elements
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: HeaderBackgroundPainter(
                      animationValue: _animController.value,
                      isHovered: _isHovered,
                    ),
                  );
                },
              ),
            ),

            // Blur effect and gradient
            Positioned.fill(
              child: ClipPath(
                clipper: OrganicShapeClipper(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Navigation Menu
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo section with hover effect
                  Padding(
                    padding: EdgeInsets.only(left: isSmallScreen ? 15 : 20),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => _handlePageTap(0),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  _currentPage == 0
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: isSmallScreen ? 40 : 50,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (!isSmallScreen) ...[
                    // Desktop navigation with improved spacing
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            _pageNames
                                .asMap()
                                .entries
                                .map(
                                  (entry) =>
                                      _buildNavItem(entry.value, entry.key),
                                )
                                .toList(),
                      ),
                    ),
                  ],

                  // Mobile menu button with improved visuals
                  if (isSmallScreen)
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.menu,
                              color: Colors.white.withOpacity(0.9),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, int index) {
    final isSelected = _currentPage == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => _handlePageTap(index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color:
                  isSelected
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
              border: Border.all(
                color:
                    isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(isSelected ? 1 : 0.8),
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Organic shape clipper for the header
class OrganicShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;

    // Start at top-left
    path.lineTo(0, height * 0.95);

    // Add organic curves at the bottom
    final double curveCount = 8;
    final double curveWidth = width / curveCount;

    for (int i = 0; i < curveCount; i++) {
      final double x1 = curveWidth * i;
      final double x2 = curveWidth * (i + 1);

      path.quadraticBezierTo(
        (x1 + x2) / 2,
        height * (0.9 + 0.1 * math.sin((i + 0.5) * math.pi)),
        x2,
        height * (0.95 + 0.05 * math.sin((i + 1) * math.pi)),
      );
    }

    // Complete the path
    path.lineTo(width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Custom painter for the animated background
class HeaderBackgroundPainter extends CustomPainter {
  final double animationValue;
  final bool isHovered;

  HeaderBackgroundPainter({
    required this.animationValue,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient background
    final Rect rect = Offset.zero & size;
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF0A0A1A), const Color(0xFF141432)],
    ).createShader(rect);

    final basePaint =
        Paint()
          ..shader = baseGradient
          ..style = PaintingStyle.fill;

    canvas.drawRect(rect, basePaint);

    // Draw moving particles/stars effect
    final particlePaint =
        Paint()
          ..color = Colors.white.withOpacity(isHovered ? 0.6 : 0.4)
          ..style = PaintingStyle.fill;

    final int particleCount = isHovered ? 30 : 20;
    for (int i = 0; i < particleCount; i++) {
      final double x = size.width * ((i * 0.1 + animationValue) % 1.0);
      final double y =
          size.height *
              0.3 *
              math.sin(
                (i / particleCount) * math.pi * 2 +
                    animationValue * math.pi * 2,
              ) +
          size.height * 0.5;

      final double scale = isHovered ? 1.2 : 1.0;
      final double radius = 1 + (i % 3) * scale;

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Draw wave line at the bottom
    final wavePaint =
        Paint()
          ..color = Colors.white.withOpacity(isHovered ? 0.15 : 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.9);

    for (double x = 0; x <= size.width; x += 1) {
      final double normalizedX = x / size.width;
      final double phase = animationValue * math.pi * 4;
      final double y =
          size.height * 0.9 +
          size.height * 0.05 * math.sin(normalizedX * 10 + phase) +
          size.height * 0.02 * math.sin(normalizedX * 20 + phase * 0.8);

      wavePath.lineTo(x, y);
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(HeaderBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isHovered != isHovered;
}

// Drawer for mobile view
class EnhancedDrawer extends StatelessWidget {
  final Function(int)? onPageChanged;
  final int currentPageIndex;

  const EnhancedDrawer({
    super.key,
    this.onPageChanged,
    this.currentPageIndex = 0,
  });

  void _handleNavigation(BuildContext context, int index) {
    Navigator.pop(context); // Close drawer
    if (onPageChanged != null) {
      onPageChanged!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF0A0A1A).withOpacity(0.95),
            const Color(0xFF141432).withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              _buildDrawerHeader(),
              const SizedBox(height: 20),
              _buildDrawerMenuItem(
                Icons.home_outlined,
                'Ana Sayfa',
                isActive: currentPageIndex == 0,
                onTap: () => _handleNavigation(context, 0),
              ),
              _buildDrawerMenuItem(
                Icons.window_outlined,
                'Kepenk Sistemleri',
                isActive: currentPageIndex == 1,
                onTap: () => _handleNavigation(context, 1),
              ),
              _buildDrawerMenuItem(
                Icons.door_sliding_outlined,
                'Endüstriyel Kapılar',
                isActive: currentPageIndex == 2,
                onTap: () => _handleNavigation(context, 2),
              ),
              _buildDrawerMenuItem(
                Icons.info_outline,
                'Hakkımızda',
                isActive: currentPageIndex == 3,
                onTap: () => _handleNavigation(context, 3),
              ),
              _buildDrawerMenuItem(
                Icons.mail_outline,
                'İletişim',
                isActive: currentPageIndex == 4,
                onTap: () => _handleNavigation(context, 4),
              ),
              const Spacer(),
              _buildDrawerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(0.1), Colors.transparent],
        ),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 100),
            const SizedBox(height: 16),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem(
    IconData icon,
    String title, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white70,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing:
            isActive
                ? const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white,
                )
                : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSocialButton(Icons.facebook),
          _buildSocialButton(Icons.web),
          _buildSocialButton(Icons.smartphone),
          _buildSocialButton(Icons.email),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }
}

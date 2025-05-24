import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class ProjectInfo {
  final String imagePath;
  final String title;
  final String description;
  final String location;
  final String date;

  ProjectInfo({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });
}

class ProjectGallery extends StatefulWidget {
  const ProjectGallery({Key? key}) : super(key: key);

  @override
  State<ProjectGallery> createState() => _ProjectGalleryState();
}

class _ProjectGalleryState extends State<ProjectGallery>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;

  final List<ProjectInfo> _projects = [
    ProjectInfo(
      imagePath: 'assets/images/Automatic_Shutter.png',
      title: 'Otomatik Kepenk Sistemi',
      description:
          'Modern tasarımlı, yüksek güvenlikli otomatik kepenk sistemi. Uzaktan kumandalı ve sensörlü çalışma özelliği.',
      location: 'Tatvan İş Merkezi',
      date: '2024',
    ),
    ProjectInfo(
      imagePath: 'assets/images/Autumatik_rof.png',
      title: 'Endüstriyel Kapı Projesi',
      description:
          'Endüstriyel tesis için özel tasarlanmış dayanıklı kapı sistemi. Yüksek performanslı motor ve gelişmiş güvenlik özellikleri.',
      location: 'Van Sanayi Bölgesi',
      date: '2023',
    ),
    ProjectInfo(
      imagePath: 'assets/images/Automatic_Shutter.png',
      title: 'Modern Kepenk Çözümü',
      description:
          'Yeni nesil teknolojilerle donatılmış, enerji verimli ve estetik tasarımlı kepenk sistemi.',
      location: 'Van Ticaret Merkezi',
      date: '2024',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth < 1024 && constraints.maxWidth >= 600;

        // Calculate optimal dimensions
        final viewportFraction =
            isMobile
                ? 0.85
                : isTablet
                ? 0.7
                : 0.6;
        final itemHeight = constraints.maxHeight * 0.8;
        final cardWidth = constraints.maxWidth * viewportFraction;

        return Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                itemCount: _projects.length,
                options: CarouselOptions(
                  height: itemHeight,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  viewportFraction: viewportFraction,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                    _fadeController.reset();
                    _fadeController.forward();
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  final project = _projects[index];
                  return FadeTransition(
                    opacity: _fadeController,
                    child: _buildProjectCard(
                      project,
                      isMobile,
                      cardWidth,
                      itemHeight,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _projects.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(
                          _currentIndex == entry.key ? 0.9 : 0.4,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(
    ProjectInfo project,
    bool isMobile,
    double cardWidth,
    double cardHeight,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image with proper sizing
            LayoutBuilder(
              builder: (context, imageConstraints) {
                return Image.asset(
                  project.imagePath,
                  fit: BoxFit.cover,
                  width: imageConstraints.maxWidth,
                  height: imageConstraints.maxHeight,
                  frameBuilder: (
                    context,
                    child,
                    frame,
                    wasSynchronouslyLoaded,
                  ) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 0.7, 0.9],
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: cardWidth * 0.05,
              right: cardWidth * 0.05,
              bottom: cardHeight * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.title,
                    style: GoogleFonts.poppins(
                      fontSize: _calculateFontSize(cardWidth, isMobile, true),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: cardHeight * 0.02),
                  Text(
                    project.description,
                    style: GoogleFonts.poppins(
                      fontSize: _calculateFontSize(cardWidth, isMobile, false),
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: cardHeight * 0.03),
                  _buildProjectInfo(project, cardWidth, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateFontSize(double cardWidth, bool isMobile, bool isTitle) {
    if (isTitle) {
      return cardWidth * (isMobile ? 0.06 : 0.045);
    }
    return cardWidth * (isMobile ? 0.035 : 0.028);
  }

  Widget _buildProjectInfo(
    ProjectInfo project,
    double cardWidth,
    bool isMobile,
  ) {
    final iconSize = cardWidth * (isMobile ? 0.04 : 0.03);
    final fontSize = cardWidth * (isMobile ? 0.03 : 0.025);

    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Colors.white.withOpacity(0.8),
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Text(
          project.location,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(width: cardWidth * 0.04),
        Icon(
          Icons.calendar_today,
          color: Colors.white.withOpacity(0.8),
          size: iconSize,
        ),
        const SizedBox(width: 4),
        Text(
          project.date,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

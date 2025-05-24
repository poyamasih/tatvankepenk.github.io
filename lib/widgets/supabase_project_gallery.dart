import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/supabase_service.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';

class SupabaseProjectGallery extends StatefulWidget {
  const SupabaseProjectGallery({Key? key}) : super(key: key);

  @override
  State<SupabaseProjectGallery> createState() => _SupabaseProjectGalleryState();
}

class _SupabaseProjectGalleryState extends State<SupabaseProjectGallery>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fadeController;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeController.forward();
    _loadGalleryItems();
  }

  Future<void> _loadGalleryItems() async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });

        final SupabaseService supabaseService = Get.find<SupabaseService>();
        final items = await supabaseService.getGalleryItems();

        // Force sync if we had to retry
        if (retryCount > 0) {
          try {
            final supabaseContentService = Get.find<SupabaseContentService>();
            await supabaseContentService.syncAllData();
            // Get fresh data after sync
            final freshItems = await supabaseService.getGalleryItems();
            if (freshItems.isNotEmpty) {
              items.clear();
              items.addAll(freshItems);
            }
          } catch (syncError) {
            debugPrint('Error during forced sync: $syncError');
          }
        }

        if (mounted) {
          setState(() {
            _projects = items;
            _isLoading = false;
          });
        }

        // If we got here successfully, break out of the retry loop
        break;
      } catch (e) {
        debugPrint(
          'Error loading gallery items (attempt ${retryCount + 1}): $e',
        );
        retryCount++;

        // If we've hit the max retries, show the error
        if (retryCount > maxRetries && mounted) {
          setState(() {
            _errorMessage = 'خطا در بارگذاری گالری: $e';
            _isLoading = false;
          });
        } else {
          // Wait a bit before retrying
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }
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
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }

        if (_errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadGalleryItems,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  child: const Text('تلاش مجدد'),
                ),
              ],
            ),
          );
        }

        if (_projects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo_album_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'هیچ تصویری در گالری یافت نشد',
                  style: GoogleFonts.vazirmatn(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

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
                  enableInfiniteScroll: _projects.length > 1,
                  autoPlay: _projects.length > 1,
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
            _projects.length > 1
                ? Row(
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
                )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(
    Map<String, dynamic> project,
    bool isMobile,
    double cardWidth,
    double cardHeight,
  ) {
    // Get values with safe fallbacks and ensure non-null values
    final title = project['title']?.toString() ?? 'بدون عنوان';
    final description = project['description']?.toString() ?? 'بدون توضیحات';
    final location = project['location']?.toString() ?? '';

    // Process image URL with proper null safety
    String imageUrl = '';
    if (project.containsKey('image_url') && project['image_url'] != null) {
      // Ensure we have a string, not null
      final urlValue = project['image_url'];
      imageUrl = urlValue is String ? urlValue : '';
    } else if (project.containsKey('image_path') &&
        project['image_path'] != null) {
      // Ensure we have a string, not null
      final pathValue = project['image_path'];
      imageUrl = pathValue is String ? pathValue : '';
    }

    // Safe date processing
    final date =
        project['date'] != null
            ? DateTime.tryParse(project['date'].toString())?.year.toString() ??
                ''
            : '';

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
                if (imageUrl.isEmpty) {
                  // Handle empty URL
                  return Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white30,
                        size: 48,
                      ),
                    ),
                  );
                }

                // Try to load the image
                return Image.network(
                  imageUrl,
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
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading image in gallery: $error');
                    return Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 48,
                        ),
                      ),
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
                    title,
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
                    description,
                    style: GoogleFonts.vazirmatn(
                      fontSize: _calculateFontSize(cardWidth, isMobile, false),
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: cardHeight * 0.03),
                  if (location.isNotEmpty || date.isNotEmpty)
                    _buildProjectInfo(
                      location: location,
                      date: date,
                      cardWidth: cardWidth,
                      isMobile: isMobile,
                    ),
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

  Widget _buildProjectInfo({
    required String location,
    required String date,
    required double cardWidth,
    required bool isMobile,
  }) {
    final iconSize = cardWidth * (isMobile ? 0.04 : 0.03);
    final fontSize = cardWidth * (isMobile ? 0.03 : 0.025);

    return Row(
      children: [
        if (location.isNotEmpty) ...[
          Icon(
            Icons.location_on,
            color: Colors.white.withOpacity(0.8),
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            location,
            style: GoogleFonts.vazirmatn(
              fontSize: fontSize,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          if (date.isNotEmpty) SizedBox(width: cardWidth * 0.04),
        ],
        if (date.isNotEmpty) ...[
          Icon(
            Icons.calendar_today,
            color: Colors.white.withOpacity(0.8),
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            date,
            style: GoogleFonts.vazirmatn(
              fontSize: fontSize,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/supabase_content_service.dart';
import 'package:tatvan_kepenk/widgets/supabase_project_gallery.dart';

class SupabaseContentSection extends StatefulWidget {
  final String title;
  final String description;
  final String imagePath;
  final String buttonText;
  final VoidCallback? onButtonPressed;
  final bool isActive;
  final int animationDelay;
  final String contentType; // "kepenk" or "kapilar"
  final bool showGallery; // Whether to show the gallery instead of the image

  const SupabaseContentSection({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.buttonText,
    this.onButtonPressed,
    this.isActive = false,
    this.animationDelay = 0,
    this.contentType = '',
    this.showGallery = false,
  }) : super(key: key);

  @override
  State<SupabaseContentSection> createState() => _SupabaseContentSectionState();
}

class _SupabaseContentSectionState extends State<SupabaseContentSection> {
  late SupabaseContentService _contentService;
  String _title = '';
  String _description = '';
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      _contentService = Get.find<SupabaseContentService>();
      _loadContent();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطا در راه‌اندازی سرویس‌ها: $e';
      });
    }
  }

  void _loadContent() {
    if (widget.contentType == 'kepenk') {
      _title = _contentService.getKepenkTitle();
      _description = _contentService.getKepenkDescription();
    } else if (widget.contentType == 'kapilar') {
      _title = _contentService.getKapilarTitle();
      _description = _contentService.getKapilarDescription();
    } else {
      _title = widget.title;
      _description = widget.description;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 800;
    final displayTitle = _title.isNotEmpty ? _title : widget.title;
    final displayDescription =
        _description.isNotEmpty ? _description : widget.description;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 20 : 40,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with gradient
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
              displayTitle,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                  fontSize: isSmallScreen ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ).animate(
            autoPlay: true,
            delay: Duration(milliseconds: 200 + widget.animationDelay),
            effects: [
              SlideEffect(
                begin: const Offset(-0.2, 0),
                end: Offset.zero,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
              ),
              FadeEffect(
                begin: 0.0,
                end: 1.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Description
          SizedBox(
            width: isSmallScreen ? screenWidth : screenWidth * 0.6,
            child: Text(
              displayDescription,
              style: GoogleFonts.vazirmatn(
                textStyle: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.6,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ).animate(
            delay: Duration(milliseconds: 300 + widget.animationDelay),
            effects: [
              SlideEffect(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
                curve: Curves.easeOutQuart,
              ),
              FadeEffect(begin: 0.0, end: 1.0, curve: Curves.easeOut),
            ],
          ),

          const SizedBox(height: 30),

          // Button
          ElevatedButton(
            onPressed: widget.onButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white10,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: Text(
              widget.buttonText,
              style: const TextStyle(color: Colors.white),
            ),
          ).animate(
            delay: Duration(milliseconds: 400 + widget.animationDelay),
            effects: [
              SlideEffect(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
                curve: Curves.easeOutQuart,
              ),
              FadeEffect(begin: 0.0, end: 1.0, curve: Curves.easeOut),
            ],
          ),

          const SizedBox(height: 40),

          // Image or Gallery
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white12,
                          Colors.white12,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child:
                        widget.showGallery
                            ? const SupabaseProjectGallery()
                            : Image.asset(
                              widget.imagePath,
                              fit: BoxFit.contain,
                            ),
                  ),
                ),
              ),
            ).animate(
              delay: Duration(milliseconds: 500 + widget.animationDelay),
              effects: [
                ScaleEffect(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutQuart,
                ),
                FadeEffect(begin: 0.0, end: 1.0, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

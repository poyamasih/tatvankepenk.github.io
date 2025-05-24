import 'package:flutter/material.dart';
import 'package:tatvan_kepenk/widgets/animated_background.dart';
import 'package:tatvan_kepenk/widgets/enhanced_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:tatvan_kepenk/services/content_storage.dart';

class AboutPageContent extends StatefulWidget {
  const AboutPageContent({super.key});

  @override
  State<AboutPageContent> createState() => _AboutPageContentState();
}

class _AboutPageContentState extends State<AboutPageContent> {
  late ContentStorage _contentStorage;
  Map<String, Map<String, String>> _aboutContent = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _contentStorage = Get.find<ContentStorage>();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Map internal sections to stored section indexes
      final Map<String, String> sectionMapping = {
        'main': '1',
        'mission': '2',
        'values': '3',
      };

      // Load content sections from storage
      for (final entry in sectionMapping.entries) {
        final section = entry.key;
        final sectionId = entry.value;

        final title = _contentStorage.getAboutTitle(int.parse(sectionId));
        final description = _contentStorage.getAboutDescription(
          int.parse(sectionId),
        );

        _aboutContent[section] = {
          'title': title.isNotEmpty ? title : _getDefaultTitle(section),
          'content':
              description.isNotEmpty
                  ? description
                  : _getDefaultContent(section),
        };
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading about content: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getDefaultTitle(String section) {
    switch (section) {
      case 'main':
        return 'Tatvan Kepenk Hakkında';
      case 'mission':
        return 'Misyonumuz';
      case 'values':
        return 'Değerlerimiz';
      default:
        return '';
    }
  }

  String _getDefaultContent(String section) {
    switch (section) {
      case 'main':
        return 'Tatvan Kepenk olarak, 10 yılı aşkın deneyimimizle otomatik kepenk ve endüstriyel kapı sistemleri alanında hizmet vermekteyiz. Müşterilerimize en kaliteli ürünleri sunmayı ve profesyonel montaj hizmetiyle güvenilir çözümler üretmeyi ilke edindik.';
      case 'mission':
        return 'Müşterilerimize en üst düzey güvenlik ve konfor sağlayan, enerji verimliliği yüksek ve estetik açıdan tatmin edici kepenk sistemleri sunmak.';
      case 'values':
        return 'Kalite, güvenilirlik, müşteri memnuniyeti ve sürekli gelişim bizim temel değerlerimizdir. Her projede bu değerlerimizi ön planda tutarak çalışıyoruz.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "HAKKIMIZDA",
                  style: GoogleFonts.montserrat(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildContentSection(
                title: _aboutContent['main']!['title']!,
                content: _aboutContent['main']!['content']!,
              ),
              const SizedBox(height: 30),
              _buildContentSection(
                title: _aboutContent['mission']!['title']!,
                content: _aboutContent['mission']!['content']!,
              ),
              const SizedBox(height: 30),
              _buildContentSection(
                title: _aboutContent['values']!['title']!,
                content: _aboutContent['values']!['content']!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// Original AboutPage that uses the content
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: EnhancedHeader(),
      ),
      body: AnimatedBackground(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 100,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: AboutPageContent(),
        ),
      ),
    );
  }
}
